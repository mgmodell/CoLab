# frozen_string_literal: true
class GraphingController < ApplicationController
  Unit_To_Processing = [['Individual', ['Summary', 'Summary By Behavior', 'All Data']],
                        ['Group', ['Summary']],
                        ['Raw Data', ['Comments']]].freeze

  # Support the app by providing the subject instances
  def subjects
    unit_of_analysis = params[:unit_of_analysis]
    project_id = params[:project_id]
    for_research = params[:for_research] == 'true' ? true : false
    anonymize = @current_user.anonymize?

    @subjects = []
    case unit_of_analysis
    when 'Individual', 'Raw Data'
      if for_research
        @subjects = User.joins(:consent_logs, :projects)
                        .where(consent_logs: { accepted: true }, projects: { id: project_id })
                        .collect { |user| [user.name(anonymize), user.id] }
      else
        @subjects = Project.find(project_id).users.collect { |user| [user.name(anonymize), user.id] }
      end
    when 'Group'
      @subjects = Project.find(project_id).groups.collect { |group| [group.get_name(anonymize), group.id] }

    end
    # Return the retrieved data
    respond_to do |format|
      format.json
    end
  end

  # Retrieve all the reported values relating to the
  # specified user and hash them up by Installment.
  def pull_and_organise_user_data(user_id, project_id, for_research = false)
    # for_research = @current_user.anonymize?
    values = []
    if for_research
      values = Value.includes(:user, :factor, installment: [:assessment, :user])
                    .joins(user: { consent_logs: { consent_form: :project } },
                           installment:  :assessment)
                    .where(consent_logs: { accepted: true },
                           user_id: user_id,
                           installments: { user_id: User.consented_to_project(project_id) },
                           projects: { id: project_id })
    else
      values = Value.includes(:user, :factor, installment: [:assessment, :user])
                    .joins(installment: :assessment)
                    .where(user_id: user_id, assessments: { project_id: project_id })
    end

    assessment_to_values = {}
    values.each do |value|
      if assessment_to_values[value.installment.assessment].nil?
        assessment_to_values[value.installment.assessment] = [value]
      else
        assessment_to_values[value.installment.assessment] << value
      end
    end
    assessment_to_values
  end

  def individual_summary_data(user, project_id, for_research = false)
    anonymize = @current_user.anonymize?
    assessment_to_values = pull_and_organise_user_data(user.id, project_id, for_research)
    data = []
    sequential = assessment_to_values.keys.sort_by(&:start_date)
    sequential.each do |assessment|
      values = assessment_to_values[assessment]
      data << { x: values[0].created_at.to_i * 1000,
                y: values.inject(0) { |sum, value| sum + value.value }.to_f / values.size,
                name: values.map{ |x| x.installment.prettyComment(anonymize) }.join( "</br>\n" ) }
    end
    series = {}
    series.store('data', data)
    series.store('label', user.name(anonymize))
    series
  end

  #
  # The graphing data is provided as a JSON object containing:
  # data_series
  #   data - an array of [date, value] arrays.
  #   label - name for the series represented by 'data'
  # detail_hash - any relevant data to be dispayed with the set
  # of series.
  def data
    unit_of_analysis = params[:unit_of_analysis]
    data_processing = params[:data_processing]
    project = Project.find(params[:project])
    subject = params[:subject]
    for_research = params[:for_research] == 'true' ? true : false
    anonymize = @current_user.anonymize?

    # TODO: - validate that the user has access to the requested data
    @data_series = []
    @detail_hash = {}

    # Do we have any business getting this data?
    if current_user.is_admin? || @current_user.rosters.instructorships.count > 0

      # Retrieve the requested data
      case unit_of_analysis
      when 'Individual'
        user = User.find(subject.to_i)
        @detail_hash.store('name', user.name(anonymize))

        case data_processing
        when 'Summary'
          series = individual_summary_data(user, project.id)
          @data_series << series
        when 'All Data'
          assessment_to_values = pull_and_organise_user_data(user.id, project.id, for_research)
          data_hash = {}
          sequential = assessment_to_values.keys.sort_by(&:start_date)
          sequential.each do |assessment|
            values = assessment_to_values[assessment]
            values.each do |value|
              series = data_hash[value.factor.id.to_s + '_' + value.installment.user_id.to_s]
              if series.nil?
                series = {}
                series.store('label', value.factor.name + ' by ' + value.installment.user.name(anonymize))
              end
              series_data = series['data']
              series_data = [] if series_data.nil?
              series_data << { x: value.created_at.to_i * 1000,
                               y: value.value,
                               name: value.installment.prettyComment(anonymize) }
              series.store('data', series_data)
              data_hash.store(value.factor.id.to_s + '_' + value.installment.user_id.to_s, series)
            end
          end
          @data_series = data_hash.values
        when 'Summary By Behavior'
          assessment_to_values = pull_and_organise_user_data(user.id, project.id, for_research)
          data_hash = {}
          # Begin by sorting by date to group all the categories properly
          sequential = assessment_to_values.keys.sort_by(&:start_date)
          sequential.each do |assessment|
            values = assessment_to_values[assessment]
            values.each do |value|
              series = data_hash[value.factor.id.to_s]
              if series.nil?
                series = {}
                series.store('label', value.factor.name)
              end
              series_data = series['data']
              series_data = [] if series_data.nil?
              series_data << { x: value.installment.assessment.start_date.to_time.to_i * 1000,
                               y: value.value,
                               name: value.installment.prettyComment(anonymize) }

              # collapsed_series_data << [ date, tmp.inject{|sum,el| sum + el[1] }.to_f / tmp.size ]
              series.store('data', series_data)
              data_hash.store(value.factor.id.to_s, series)
            end
          end
          data_hash.each_pair do |_key, value|
            tmp = []
            date = value['data'][0][:x]
            new_collapsed_data = []
            value['data'].each do |v|
              if v[:x] != date
                comments = value['data'].uniq.collect { |datum| datum[:name] + "\n" }.join('</br>')
                new_collapsed_data << { x: date,
                                        y: tmp.inject { |sum, el| sum + el }.to_f / tmp.size,
                                        name: comments }
                date = v[:x]
                tmp = []
               end
              tmp << v[:y]
            end
            value['data'] = new_collapsed_data
          end
          @data_series = data_hash.values
        end
      when 'Group'
        group = Group.find(subject.to_i)
        @detail_hash.store('name', group.get_name(anonymize))

        case data_processing
        when 'Summary'
          group.users.each do |user|
            @data_series << individual_summary_data(user, project.id)
          end
        end
      when 'Raw Data'
        user = User.confirmed.find(subject.to_i)
        @detail_hash.store('name', user.name(anonymize))

        case data_processing
        when 'Comments'
          installments = Installment.joins(:assessment)
                                    .where(user_id: subject.to_i, assessment: assessment)
          @data = installments
          respond_to do |format|
            format.csv do
              if anonymize
                headers['Content-Disposition'] = "attachment; filename=\"#{user.anon_last_name}_#{user.anon_first_name}.csv\""
              else
                headers['Content-Disposition'] = "attachment; filename=\"#{user.last_name}_#{user.first_name}.csv\""
              end
              headers['Content-Type'] ||= 'text/csv'
            end
          end
        end
      end
    else
      @data_series = { 'label' => 'Restricted', 'data' => [] }
      @detail_hash.store('name', 'Restricted: You do not have permission to access this data')
    end

    # Other stuff here

    # Return the retrieved data
    respond_to do |format|
      format.json
    end
  end

  def index
    @title = 'Reports'
    @user = current_user
    @current_users_projects = []

    # Get the assessments administered by the current user
    if @user.is_instructor?
      if @user.is_admin?
        @current_users_projects = Project.all
      elsif @user.is_instructor?
        Roster.instructorships.where(user_id: @user.id).each do |roster|
          @current_users_projects.concat roster.course.projects.to_a
        end
      end
      return @current_users_projects
    else
      redirect_to root_url
    end
  end

  #
  # Sometimes you want the raw data to play with yourself.
  #
  def raw_data
    user = User.find(subject.to_i)
    anonymize = @current_user.anonymize?

    installments = Installment.joins(:assessment)
                              .where(user_id: subject.to_i, assessment: { project_id: assessment.to_i })
    @data = installments
    respond_to do |format|
      format.csv do
        if anonymize
          headers['Content-Disposition'] = "attachment; filename=\"#{user.anon_last_name}_#{user.anon_first_name}.csv\""
        else
          headers['Content-Disposition'] = "attachment; filename=\"#{user.last_name}_#{user.first_name}.csv\""
        end
        headers['Content-Type'] ||= 'text/csv'
      end
    end
  end
end

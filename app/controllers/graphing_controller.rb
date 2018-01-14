# frozen_string_literal: true
class GraphingController < ApplicationController
  Unit_Of_Analysis = { group: 2, individual: 1 }.freeze

  def index
    @title = 'Reports'
    @user = current_user
    @current_users_projects = []

    # Get the assessments administered by the current user
    if @user.is_instructor?
      if @user.is_admin?
        @current_users_projects = Project.all
      elsif @user.is_instructor?
        Roster.instructor.where(user_id: @user.id).each do |roster|
          @current_users_projects.concat roster.course.projects.to_a
        end
      end
      return @current_users_projects
    else
      redirect_to root_url
    end
  end

  def projects
    for_research = params[:for_research] == 'true' ? true : false
    anon_req = params[:anonymous] == 'true' ? true : false
    anonymize = @current_user.anonymize? || @current_user.is_researcher? || anon_req
    projects = []
    if @current_user.admin || @current_user.is_researcher?
      project_list = Project.all.to_a
    else
      project_list = Project.joins(course: :rosters)
                            .where('rosters.user': @current_user,
                                   'rosters.role': Roster.roles[:instructor])
                            .uniq.to_a
    end
    project_list.collect! { |project| { id: project.id, name: project.get_name(anonymize) } }
    respond_to do |format|
      format.json { render json: project_list }
    end
  end

  # Support the app by providing the subject instances
  def subjects
    unit_of_analysis = params[:unit_of_analysis].to_i
    project_id = params[:project_id]
    for_research = params[:for_research] == 'true' ? true : false
    anon_req = params[:anonymous] == 'true' ? true : false
    anonymize = @current_user.anonymize? || anon_req

    subjects = []
    case unit_of_analysis
    when Unit_Of_Analysis[:individual]
      if for_research
        subjects = User.joins(:consent_logs, :projects)
                       .where(consent_logs: { accepted: true }, projects: { id: project_id })
                       .collect { |user| [user.name(anonymize), user.id] }
      else
        subjects = Project.find(project_id).users.collect { |user| [user.name(anonymize), user.id] }
      end
    when Unit_Of_Analysis[:group]
      subjects = Project.find(project_id).groups.collect { |group| [group.get_name(anonymize), group.id] }

    end
    # Return the retrieved data
    respond_to do |format|
      format.json { render json: subjects }
    end
  end

  def data
    unit_of_analysis = params[:unit_of_analysis].to_i
    project = Project.find(params[:project])
    subject = params[:subject]
    for_research = params[:for_research] == 'true' ? true : false
    anon_req = params[:anonymous] == 'true' ? true : false
    anonymize = @current_user.anonymize? || anon_req

    dataset = {
      unitOfAnalysis: nil,
      comments: {},
      project_name: project.get_name(anonymize),
      project_id: project.id,
      start_date: project.start_date,
      end_date: project.end_date,
      streams: {}
    }
    comments = dataset[:comments]
    streams = dataset[:streams]
    # Security checks
    if @current_user.is_admin? ||
       project.course.instructors.includes(@current_user)
      # Start pulling data

      groups = {}
      case unit_of_analysis
      when Unit_Of_Analysis[:individual]
        dataset[:unitOfAnalysis] = I18n.t(:individual)
        dataset[:unitOfAnalysisCode] = 'i'
        user = User.find subject
        dataset[:subject_id] = user.id
        dataset[:subject] = user.informal_name(anonymize)
        values = Value.joins(installment: :assessment)
                      .where('assessments.project_id': project, user: user)
                      .includes(:factor, installment: [:user, :group])
                      .order('installments.inst_date')

        values.each do |value|
          group_vals = streams[value.installment.group_id]
          if group_vals.nil?
            group = value.installment.group

            groups[group.id] = { group_name: group.get_name(anonymize),
                                 group_id: group.id }
            group_vals = { target_name: value.installment.group.get_name(anonymize),
                           target_id: value.installment.group_id,
                           sub_streams: {} }
          end
          user_stream = group_vals[:sub_streams][value.installment.user_id]
          if user_stream.nil?
            user_stream = { assessor_id: value.installment.user_id,
                            assessor_name: value.installment.user.informal_name(anonymize),
                            factor_streams: {} }
            group_vals[:sub_streams][value.installment.user_id] = user_stream
          end
          factor_stream = user_stream[:factor_streams][value.factor_id]
          if factor_stream.nil?
            factor_stream = { factor_name: value.factor.name,
                              factor_id: value.factor_id,
                              values: [] }
            user_stream[:factor_streams][value.factor_id] = factor_stream
          end
          factor_stream[:values] << {
            assessment_id: value.installment.assessment_id,
            installment_id: value.installment_id,
            date: value.installment.inst_date,
            value: value.value
          }
          streams[value.installment.group_id] = group_vals

          comments[value.installment_id] = {
            comment: value.installment.pretty_comment(anonymize),
            commentor: value.installment.user.name(anonymize)
          }
        end

      when Unit_Of_Analysis[:group]
        dataset[:unitOfAnalysis] = I18n.t(:group)
        dataset[:unitOfAnalysisCode] = 'g'
        group = Group.find subject
        groups[group.id] = { group_name: group.get_name(anonymize),
                             group_id: group.id }
        dataset[:subject_id] = group.id
        dataset[:subject] = group.get_name(anonymize)
        values = Value.joins(installment: :assessment)
                      .where('assessments.project_id': project,
                             'installments.group_id': group)
                      .includes(:user, :factor, installment: [:user, :assessment])
                      .order('installments.inst_date')

        values.each do |value|
          user_vals = streams[value.user_id]
          if user_vals.nil?
            user_vals = { target_name: value.user.name(anonymize),
                          target_id: value.user_id,
                          sub_streams: {} }
          end
          user_stream = user_vals[:sub_streams][value.installment.user_id]
          if user_stream.nil?
            user_stream = { assessor_id: value.installment.user_id,
                            assessor_name: value.installment.user.informal_name(anonymize),
                            factor_streams: {} }
            user_vals[:sub_streams][value.installment.user_id] = user_stream
          end
          factor_stream = user_stream[:factor_streams][value.factor_id]
          if factor_stream.nil?
            factor_stream = { factor_name: value.factor.name,
                              factor_id: value.factor_id,
                              values: [] }
            user_stream[:factor_streams][value.factor_id] = factor_stream
          end
          factor_stream[:values] << {
            assessment_id: value.installment.assessment_id,
            installment_id: value.installment_id,
            date: value.installment.inst_date,
            close_date: value.installment.assessment.end_date,
            factor: value.factor.name,
            value: value.value
          }
          streams[value.user_id] = user_vals

          comments[value.installment_id] = {
            comment: value.installment.pretty_comment(anonymize),
            commentor: value.installment.user.name(anonymize)
          }
        end
      end
    end

    factors = {}
    users = {}
    dataset[:streams].values.each do |stream|
      stream[:sub_streams].values.each do |substream|
        users[substream[:assessor_id]] = {
          name: substream[:assessor_name],
          id: substream[:assessor_id]
        }
        substream[:factor_streams].values.each do |factor_stream|
          factors[factor_stream[:factor_id]] = {
            name: factor_stream[:factor_name],
            id: factor_stream[:factor_id]
          }
        end
      end
    end
    dataset[:users] = users
    dataset[:factors] = factors
    dataset[:groups] = groups

    # Return the retrieved data
    respond_to do |format|
      format.json { render json: dataset }
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

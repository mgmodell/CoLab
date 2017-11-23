# frozen_string_literal: true
class GraphingController < ApplicationController
  Unit_Of_Analysis = { individual: 1, group: 2 }.freeze

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

  # Support the app by providing the subject instances
  def subjects
    unit_of_analysis = params[:unit_of_analysis].to_i
    project_id = params[:project_id]
    for_research = params[:for_research] == 'true' ? true : false
    anonymize = @current_user.anonymize?

    subjects = []
    case unit_of_analysis
    when Unit_Of_Analysis[ :individual ]
      if for_research
        subjects = User.joins(:consent_logs, :projects)
                        .where(consent_logs: { accepted: true }, projects: { id: project_id })
                        .collect { |user| [user.name(anonymize), user.id] }
      else
        subjects = Project.find(project_id).users.collect { |user| [user.name(anonymize), user.id] }
      end
    when Unit_Of_Analysis[ :group ]
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
    anonymize = @current_user.anonymize?

    dataset = { unitOfAnalysis: nil, comments: {}, streams: { } }
    comments = dataset[ :comments ]
    streams = dataset[ :streams ]
    #Security checks
    if @current_user.is_admin? ||
        project.course.instructors.includes( @current_user )
      #Start pulling data

      case unit_of_analysis
      when Unit_Of_Analysis[ :individual ]
        dataset[ :unitOfAnalysis ] = I18n.t( :individual )
        user = User.find subject
        dataset[ :subject ] = user.informal_name( anonymize )
        values = Value.joins( installment: :assessment ).
                          where( 'assessments.project_id': project, user: user ).
                          includes( :factor, installment: [:user, :group ]).
                          order( 'installments.inst_date' )

        values.each do |value|
          group_vals = streams[ value.installment.group_id ]
          if group_vals.nil?
            group_vals = { target_name: value.installment.group.get_name( anonymize ),
                          target_id: value.installment.group_id,
                          values: Array.new }
          end
          group_vals[ :values ] << {
            assessor_id: value.installment.user_id,
            assessor_name: value.installment.user.name( anonymize ),
            assessment_id: value.installment.assessment_id,
            installment_id: value.installment_id,
            date: value.installment.inst_date,
            factor: value.factor.name,
            value: value.value }
          streams[ value.installment.group_id ] = group_vals

          comments[ value.installment_id ] =
                    value.installment.prettyComment( anonymize )

        end

      when Unit_Of_Analysis[ :group ]
        dataset[ :unitOfAnalysis ] = I18n.t( :group )
        group = Group.find subject
        dataset[ :subject ] = group.get_name( anonymize )
        values = Value.joins( installment: :assessment ).
                          where( 'assessments.project_id': project,
                          'installments.group_id': group ).
                          includes( :user, :factor, installment: :user ).
                          order( 'installments.inst_date' )

        values.each do |value|
          user_vals = streams[ value.user_id ]
          if user_vals.nil?
            user_vals = { target_name: value.user.name( anonymize ),
                          target_id: value.user_id,
                          values: Array.new }
          end
          user_vals[ :values ] << {
            assessor_id: value.installment.user_id,
            assessor_name: value.installment.user.name( anonymize ),
            assessment_id: value.installment.assessment_id,
            installment_id: value.installment_id,
            date: value.installment.inst_date,
            factor: value.factor.name,
            value: value.value }
          streams[ value.user_id ] = user_vals

          comments[ value.installment_id ] =
                    value.installment.prettyComment( anonymize )

        end
      end
    else
      #Return some sort of error
    
    end


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

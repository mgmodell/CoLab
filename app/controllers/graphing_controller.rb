# frozen_string_literal: true

class GraphingController < ApplicationController
  Unit_Of_Analysis = { group: 2, individual: 1 }.freeze

  def index
    @user = current_user
    current_users_projects = []

    # Get the assessments administered by the current user
    if @user.is_instructor?
      if @user.is_admin?
        current_users_projects = Project.all
      elsif @user.is_instructor?
        Roster.instructor.where( user_id: @user.id ).find_each do | roster |
          current_users_projects.concat roster.course.projects.to_a
        end
      end
      current_users_projects
    else
      redirect_to root_url
    end
  end

  def projects
    params[:for_research]
    anon_req = params[:anonymous]
    anonymize = current_user.anonymize? || current_user.is_researcher? || anon_req
    project_list = if current_user.admin || current_user.is_researcher?
                     Project.all.to_a
                   else
                     Project.joins( course: :rosters )
                            .where( 'rosters.user': current_user,
                                    'rosters.role': Roster.roles[:instructor] )
                            .uniq.to_a
                   end
    project_list.collect! { | project | { id: project.id, name: project.get_name( anonymize ) } }

    project_list.sort_by! { | a | a[:name] }
    respond_to do | format |
      format.json { render json: project_list }
    end
  end

  # Support the app by providing the subject instances
  def subjects
    unit_of_analysis = params[:unit_of_analysis].to_i
    project_id = params[:project_id]
    for_research = params[:for_research]
    anon_req = params[:anonymous]
    anonymize = current_user.anonymize? || anon_req

    subjects = []
    case unit_of_analysis
    when Unit_Of_Analysis[:individual]
      subjects = if for_research
                   User.joins( :consent_logs, :projects )
                       .where( consent_logs: { accepted: true }, projects: { id: project_id } )
                       .collect { | user | [user.name( anonymize ), user.id] }
                 else
                   Project.find( project_id ).users.collect { | user | { name: user.name( anonymize ), id: user.id } }
                 end
    when Unit_Of_Analysis[:group]
      subjects = Project.find( project_id ).groups.collect do | group |
        { name: group.get_name( anonymize ), id: group.id }
      end

    end

    subjects.sort_by! { | a | a[:name] }
    # Return the retrieved data
    respond_to do | format |
      format.json { render json: subjects }
    end
  end

  def data
    unit_of_analysis = params[:unit_of_analysis].to_i
    project = Project.find( params[:project] )
    subject = params[:subject]
    params[:for_research]
    anon_req = params[:anonymous]
    anonymize = current_user.anonymize? || anon_req

    offset = anonymize ? project.course_anon_offset : 0

    dataset = {
      unitOfAnalysis: nil,
      comments: {},
      project_name: project.get_name( anonymize ),
      project_id: project.id,
      start_date: project.start_date + offset,
      end_date: project.end_date + offset,
      streams: {}
    }
    comments = dataset[:comments]
    streams = dataset[:streams]
    users = {}
    # Security checks
    if current_user.is_admin? ||
       project.course.instructors.include?( current_user )
      # Start pulling data

      groups = {}
      case unit_of_analysis
      when Unit_Of_Analysis[:individual]
        dataset[:unitOfAnalysis] = I18n.t( :individual )
        dataset[:unitOfAnalysisCode] = 'i'
        user = User.find subject
        dataset[:subject_id] = user.id
        dataset[:subject] = user.informal_name( anonymize )
        values = Value.joins( installment: :assessment )
                      .where( 'assessments.project_id': project, user: )
                      .includes( :factor, installment: %i[user group] )
                      .order( 'installments.inst_date' )

        values.each do | value |
          group_vals = streams[value.installment_group_id]
          if group_vals.nil?
            group = value.installment.group

            groups[group.id] = { group_name: group.get_name( anonymize ),
                                 group_id: group.id }
            group_vals = { target_name: value.installment_group.get_name( anonymize ),
                           target_id: value.installment_group_id,
                           sub_streams: {} }
          end
          user_stream = group_vals[:sub_streams][value.installment_user_id]
          users[value.installment_user_id] = {
            name: value.installment_user.name( anonymize ),
            id: value.installment_user_id
          }
          if user_stream.nil?
            user_stream = { assessor_id: value.installment_user_id,
                            assessor_name: value.installment_user.informal_name( anonymize ),
                            factor_streams: {} }
            group_vals[:sub_streams][value.installment_user_id] = user_stream
          end
          factor_stream = user_stream[:factor_streams][value.factor_id]
          if factor_stream.nil?
            factor_stream = { factor_name: value.factor.name,
                              factor_id: value.factor_id,
                              values: [] }
            user_stream[:factor_streams][value.factor_id] = factor_stream
          end
          factor_stream[:values] << {
            assessment_id: value.installment_assessment_id,
            installment_id: value.installment_id,
            date: value.installment_inst_date + offset,
            value: value.value
          }
          streams[value.installment_group_id] = group_vals

          comments[value.installment_id] = {
            comment: value.installment.pretty_comment( anonymize ),
            commentor: value.installment_user.name( anonymize )
          }
        end

      when Unit_Of_Analysis[:group]
        dataset[:unitOfAnalysis] = I18n.t( :group )
        dataset[:unitOfAnalysisCode] = 'g'
        group = Group.find subject
        groups[group.id] = { group_name: group.get_name( anonymize ),
                             group_id: group.id }
        dataset[:subject_id] = group.id
        dataset[:subject] = group.get_name( anonymize )
        values = Value.joins( installment: :assessment )
                      .where( 'assessments.project_id': project,
                              'installments.group_id': group )
                      .includes( :user, :factor, installment: %i[user assessment] )
                      .order( 'installments.inst_date' )

        values.each do | value |
          user_vals = streams[value.user_id]
          users[value.user_id] = {
            name: value.user.name( anonymize ),
            id: value.user_id
          }
          if user_vals.nil?
            user_vals = { target_name: value.user_name( anonymize ),
                          target_id: value.user_id,
                          sub_streams: {} }
          end
          user_stream = user_vals[:sub_streams][value.installment_user_id]
          if user_stream.nil?
            user_stream = { assessor_id: value.installment_user_id,
                            assessor_name: value.installment_user.informal_name( anonymize ),
                            factor_streams: {} }
            user_vals[:sub_streams][value.installment_user_id] = user_stream
          end
          factor_stream = user_stream[:factor_streams][value.factor_id]
          if factor_stream.nil?
            factor_stream = { factor_name: value.factor.name,
                              factor_id: value.factor_id,
                              values: [] }
            user_stream[:factor_streams][value.factor_id] = factor_stream
          end
          factor_stream[:values] << {
            assessment_id: value.installment_assessment_id,
            installment_id: value.installment_id,
            date: value.installment_inst_date + offset,
            close_date: value.installment_assessment.end_date + offset,
            factor: value.factor_name,
            value: value.value
          }
          streams[value.user_id] = user_vals

          comments[value.installment_id] = {
            comment: value.installment.pretty_comment( anonymize ),
            commentor: value.installment.user.name( anonymize )
          }
        end
      end
    end

    factors = {}
    dataset[:streams].each_value do | stream |
      stream[:sub_streams].each_value do | substream |
        substream[:factor_streams].each_value do | factor_stream |
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
    respond_to do | format |
      format.json { render json: dataset }
    end
  end
end

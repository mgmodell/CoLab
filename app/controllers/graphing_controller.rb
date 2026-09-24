# frozen_string_literal: true

#Optimizations suggested by Gemini
class GraphingController < ApplicationController
  skip_before_action :authenticate_user!
  
  # OPTIMIZATION: Converted non-standard capital constants to standard Ruby conventions
  UNIT_OF_ANALYSIS = { group: 2, individual: 1 }.freeze
  OPEN_PROJECTS = [24, 5, 6, 7, 19, 22, 23].freeze

  def projects
    anonymize = anonymize_for_projects?
    
    # OPTIMIZATION: Removed .to_a calls that forced immediate evaluation and heavy 
    # memory allocation into Ruby arrays before completing query construction.
    projects_scope = if user_authorized_for_all?
                       Project.all
                     elsif current_user&.is_instructor?
                       # OPTIMIZATION: Used symbol keys in hash condition for better performance & readability
                       Project.joins(course: :rosters)
                              .where(rosters: { user_id: current_user.id, role: Roster.roles[:instructor] })
                              .distinct
                     else
                       Project.where(id: OPEN_PROJECTS)
                     end

    # REFACTOR: Streamlined array transformation with .map instead of mutating .collect!
    project_list = projects_scope.map { |project| { id: project.id, name: project.get_name(anonymize) } }
    project_list.sort_by! { |p| p[:name] }

    respond_to do |format|
      format.json { render json: project_list }
    end
  end

  # Support the app by providing the subject instances
  def subjects
    unit_of_analysis = params[:unit_of_analysis].to_i
    project_id = params[:project_id]

    # REFACTOR: Early exit guard clause reduces deeply nested conditional logic
    return render json: [] unless allowed_access?(project_id)

    anonymize = current_user.nil? || current_user.anonymize? || params[:anonymous]

    subjects = case unit_of_analysis
               when UNIT_OF_ANALYSIS[:individual]
                 fetch_individual_subjects(project_id, anonymize)
               when UNIT_OF_ANALYSIS[:group]
                 fetch_group_subjects(project_id, anonymize)
               else
                 []
               end

    subjects.sort_by! { |a| a[:name] }

    respond_to do |format|
      format.json { render json: subjects }
    end
  end

  def data
    project_id = params[:project]
    
    # REFACTOR: Early return prevents processing or db hits if unauthenticated/unauthorized
    return render json: {} unless allowed_access?(project_id)

    project = Project.find(project_id)
    anonymize = should_anonymize_data?(project)
    offset = anonymize ? project.course_anon_offset : 0

    unit_of_analysis = params[:unit_of_analysis].to_i
    subject_id = params[:subject]

    dataset = build_base_dataset(project, offset)
    
    # OPTIMIZATION (CRITICAL): Eager loading via .includes eliminates severe N+1 query bottlenecks.
    # Pre-loads factor, user, installment, and installment associations (group, user, assessment)
    # in 2-3 queries total instead of issuing thousands of SQL queries inside the loop.
    values = Value.joins(installment: :assessment)
                  .includes(:factor, :user, installment: [:user, :group, :assessment])
                  .order('installments.inst_date ASC')

    case unit_of_analysis
    when UNIT_OF_ANALYSIS[:individual]
      dataset[:unitOfAnalysis] = I18n.t(:individual)
      dataset[:unitOfAnalysisCode] = 'i'
      user = User.find(subject_id)
      dataset[:subject_id] = user.id
      dataset[:subject] = user.informal_name(anonymize)

      values = values.where(assessments: { project_id: project.id }, user_id: user.id)
      process_individual_values(values, dataset, anonymize, offset)

    when UNIT_OF_ANALYSIS[:group]
      dataset[:unitOfAnalysis] = I18n.t(:group)
      dataset[:unitOfAnalysisCode] = 'g'
      group = Group.find(subject_id)
      dataset[:groups][group.id] = { group_name: group.get_name(anonymize), group_id: group.id }
      dataset[:subject_id] = group.id
      dataset[:subject] = group.get_name(anonymize)

      values = values.where(assessments: { project_id: project.id }, installments: { group_id: group.id })
      process_group_values(values, dataset, anonymize, offset)
    end

    extract_factors!(dataset)

    respond_to do |format|
      format.json { render json: dataset }
    end
  end

  private

  # REFACTOR: Extracted authorization logic into concise helper methods
  def allowed_access?(project_id)
    return true if OPEN_PROJECTS.include?(project_id.to_i)
    return false if current_user.nil?

    current_user.is_admin? || current_user.is_instructor? || current_user.is_researcher?
  end

  def user_authorized_for_all?
    current_user.present? && (current_user.is_admin? || current_user.is_researcher?)
  end

  def anonymize_for_projects?
    return true if current_user.nil?

    current_user.anonymize? || current_user.is_researcher? || params[:anonymous].present? ||
      !(current_user.is_admin? || current_user.is_instructor?)
  end

  def should_anonymize_data?(project)
    return true if current_user.nil? || current_user.anonymize? || params[:anonymous].present? || current_user.is_researcher?
    return false if current_user.is_admin?

    current_user.is_instructor? && !project.course.instructors.include?(current_user)
  end

  # OPTIMIZATION: Querying directly via Group scope avoids loading full Project instance unnecessarily
  def fetch_individual_subjects(project_id, anonymize)
    if params[:for_research]
      User.joins(:consent_logs, :projects)
          .where(consent_logs: { accepted: true }, projects: { id: project_id })
          .distinct
          .map { |user| { name: user.name(anonymize), id: user.id } }
    else
      Project.find(project_id).users.map { |user| { name: user.name(anonymize), id: user.id } }
    end
  end

  def fetch_group_subjects(project_id, anonymize)
    Group.where(project_id: project_id).map do |group|
      { name: group.get_name(anonymize), id: group.id }
    end
  end

  def build_base_dataset(project, offset)
    {
      unitOfAnalysis: nil,
      comments: {},
      project_name: project.get_name(should_anonymize_data?(project)),
      project_id: project.id,
      start_date: project.start_date + offset,
      end_date: project.end_date + offset,
      streams: {},
      users: {},
      groups: {},
      factors: {}
    }
  end

  # REFACTOR & OPTIMIZATION: 
  # 1. Extracted heavy iteration loop out of main controller action.
  # 2. Replaced multi-line `if x.nil? ... x = ...` manual initializations with `||=` operator.
  # 3. Eliminated redundant dynamic method calls (e.g., calling `value.installment_group` repeatedly).
  def process_individual_values(values, dataset, anonymize, offset)
    streams = dataset[:streams]
    comments = dataset[:comments]
    users = dataset[:users]
    groups = dataset[:groups]

    values.each do |value|
      # Local variables store eager-loaded records to avoid repetitive method dispatch
      inst = value.installment
      group = inst.group
      inst_user = inst.user

      # OPTIMIZATION: Memoized hash assignment with ||= prevents duplicate work
      groups[group.id] ||= { group_name: group.get_name(anonymize), group_id: group.id }
      users[inst_user.id] ||= { name: inst_user.name(anonymize), id: inst_user.id }

      group_vals = streams[inst.group_id] ||= {
        target_name: group.get_name(anonymize),
        target_id: inst.group_id,
        sub_streams: {}
      }

      user_stream = group_vals[:sub_streams][inst_user.id] ||= {
        assessor_id: inst_user.id,
        assessor_name: inst_user.informal_name(anonymize),
        factor_streams: {}
      }

      factor_stream = user_stream[:factor_streams][value.factor_id] ||= {
        factor_name: value.factor.name,
        factor_id: value.factor_id,
        values: []
      }

      factor_stream[:values] << {
        assessment_id: inst.assessment_id,
        installment_id: inst.id,
        date: inst.inst_date + offset,
        value: value.value
      }

      comments[inst.id] ||= {
        comment: inst.pretty_comment(anonymize),
        commentor: inst_user.name(anonymize)
      }
    end
  end

  def process_group_values(values, dataset, anonymize, offset)
    streams = dataset[:streams]
    comments = dataset[:comments]
    users = dataset[:users]

    values.each do |value|
      inst = value.installment
      val_user = value.user
      inst_user = inst.user

      users[val_user.id] ||= { name: val_user.name(anonymize), id: val_user.id }

      user_vals = streams[val_user.id] ||= {
        target_name: val_user.name(anonymize),
        target_id: val_user.id,
        sub_streams: {}
      }

      user_stream = user_vals[:sub_streams][inst_user.id] ||= {
        assessor_id: inst_user.id,
        assessor_name: inst_user.informal_name(anonymize),
        factor_streams: {}
      }

      factor_stream = user_stream[:factor_streams][value.factor_id] ||= {
        factor_name: value.factor.name,
        factor_id: value.factor_id,
        values: []
      }

      # OPTIMIZATION: Access factor.name from preloaded relation directly instead of delegates
      factor_stream[:values] << {
        assessment_id: inst.assessment_id,
        installment_id: inst.id,
        date: inst.inst_date + offset,
        close_date: inst.assessment.end_date + offset,
        factor: value.factor.name,
        value: value.value
      }

      comments[inst.id] ||= {
        comment: inst.pretty_comment(anonymize),
        commentor: inst_user.name(anonymize)
      }
    end
  end

  def extract_factors!(dataset)
    factors = {}
    dataset[:streams].each_value do |stream|
      stream[:sub_streams].each_value do |substream|
        substream[:factor_streams].each_value do |factor_stream|
          factors[factor_stream[:factor_id]] ||= {
            name: factor_stream[:factor_name],
            id: factor_stream[:factor_id]
          }
        end
      end
    end
    dataset[:factors] = factors
  end
end
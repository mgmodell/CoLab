# frozen_string_literal: true

class InstallmentsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:demo_complete]

  def edit
    @title = t 'installments.title'
    assessment_id = params[:assessment_id]

    project = Assessment.find(assessment_id).project
    if !project.nil? && !project.consent_form.nil? &&
       ConsentLog.where(user_id: current_user.id,
                        consent_form_id: project.consent_form.id,
                        presented: true).empty?
      redirect_to controller: 'consent_log', action: 'edit',
                  consent_form_id: project.consent_form.id
    else

      group_id = params[:group_id]
      @group = Group.find(group_id)
      # validate that current_user is in the
      user_id = current_user.id

      @installment = Installment.includes(values: %i[factor user], assessment: :project)
                                .where(assessment_id: assessment_id,
                                       user_id: user_id,
                                       group_id: group_id).first

      # generate the values
      @project = @installment.assessment.project
      @factors = @installment.assessment.project.factors
      @project_name = @installment.assessment.project.name
      @members = @group.users

      render @project.style.filename
    end
  end

  def update
    @title = t 'installments.title'
    @installment = Installment.find(params[:id])
    if @installment.update_attributes(i_params)
      notice = t('installments.success')
      redirect_to root_url, notice: notice
    else
      @group = Group.find(@installment.group)
      @project = @installment.assessment.project
      @factors = @installment.assessment.project.factors
      @project_name = @installment.assessment.project.name
      @members = @group.users
      render action: 'edit'
    end
  end

  def new
    @title = t 'installments.title'
    assessment_id = params[:assessment_id]
    if assessment_id == -1
      redirect_to root_path
    else

      project = Assessment.find(assessment_id).project
      if !project.nil? && !project.consent_form.nil? &&
         ConsentLog.joins(:consent_form)
                   .where('consent_logs.user_id = ? AND consent_form_id = ? AND ( presented = ? OR consent_forms.active = ? )',
                          current_user.id, project.consent_form.id, true, false).empty?
        redirect_to edit_consent_log_path(consent_form_id: project.consent_form.id)
      else

        group_id = params[:group_id]
        @group = Group.find(group_id)
        # validate that current_user is in the
        user_id = current_user.id

        @installment = Installment.new(assessment_id: assessment_id,
                                       user_id: user_id,
                                       inst_date: DateTime.current.in_time_zone(project.course.timezone),
                                       group_id: group_id)
        # @installment.user = current_user

        # generate the values
        @project = @installment.assessment.project
        @factors = @installment.assessment.project.factors
        @project_name = @installment.assessment.project.name
        @members = @group.users
        # removed proactive build of value objects.

        cell_value = Installment::TOTAL_VAL / @members.size
        @members.each do |u|
          @factors.each do |b|
            @installment.values.build(factor: b, user: u, value: cell_value)
          end
        end

        render @project.style.filename
      end
    end
  end

  def create
    @title = t 'installments.title'
    @installment = Installment.new(i_params)

    # Handle a demo run
    if @installment.assessment_id < 0
      flash[:notice] = t 'installments.demo_success'
      redirect_to root_url
    else
      redirected = false

      # I need to figure out these redirects properly
      found = false
      @installment.group.users.each do |user|
        found = true if current_user == user
      end

      if !found
        redirect_to root_url error: (t 'installments.err_not_member')
      elsif @installment.save
        project = @installment.assessment.project
        flash[:notice] = t 'installments.success'
        redirect_to root_url unless redirected
      else
        @factors = @installment.assessment.project.factors
        @project_name = @installment.assessment.project.name
        @group = @installment.group

        @members = @installment.values_by_user.keys
        if @installment.errors[:base].any?
          flash[:error] = @installment.errors[:base][0]
          redirect_to root_url
        else
          flash[:error] = t 'installments.err_unknown'
          render @installment.assessment.project.style.filename
        end

      end
    end
  end

  class UserStub
    attr_accessor :id
    attr_accessor :first_name
    attr_accessor :last_name
    def name
      last_name + ', ' + first_name
    end
  end
  class ProjStub
    attr_accessor :style, :name

    def get_name(_anon)
      name
    end
  end
  class GroupStub
    attr_accessor :name
    attr_accessor :users
    attr_accessor :project

    def get_name(_anon)
      name
    end
  end

  def demo_complete
    @title = t 'installments.demo_title'
    @project = ProjStub.new
    @project.style = Style.find(2)
    @project.name = t :demo_project

    @group = GroupStub.new
    @group.name = t :demo_group
    user_names = [%w[Doe Robert],
                  %w[Jones Roberta], %w[Kim Janice]]
    @group.users = []
    @group.project = @project

    @group.users << if @current_user.nil?
                      User.new(first_name: 'John', last_name: 'Smith')
                    else
                      @current_user
                    end

    user_names.each do |name|
      u = User.new(last_name: name[0], first_name: name[1])
      @group.users << u
    end

    @installment = Installment.new(user_id: -1, assessment_id: -1, group_id: -1)

    @factors = FactorPack.find(1).factors

    @members = @group.users
    cell_value = Installment::TOTAL_VAL / @members.size
    @members.each do |_u|
      @factors.each do |b|
        @installment.values.build(factor: b, user: _u, value: cell_value)
      end
    end

    render @project.style.filename
  end

  private

  def i_params
    params.require(:installment).permit(:inst_date, :comments, :group_id, :user_id, :assessment_id, :group_id,
                                        values_attributes: %i[factor_id user_id value])
  end
end

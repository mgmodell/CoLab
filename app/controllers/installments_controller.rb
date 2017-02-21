class InstallmentsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :demo ]

  def edit
    assessment_id = params[:assessment_id]

    project = Assessment.find(assessment_id).project
    if !project.nil? && !project.consent_form.nil? &&
       ConsentLog.where('user_id = ? AND consent_form_id = ? AND presented = ?',
                        current_user.id, project.consent_form.id, true).empty?
      redirect_to controller: 'consent_log', action: 'edit',
                  consent_form_id: project.consent_form.id
    else

      group_id = params[:group_id]
      @group = Group.find(group_id)
      # validate that current_user is in the
      user_id = current_user.id

      @installment = Installment.includes(values: [:behaviour, :user], assessment: :project)
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
    @installment = Installment.find(params[:id])
    if @installment.update_attributes(params[:installment])
      redirect_to root_url, notice: 'Installment successfully updated'
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
    assessment_id = params[:assessment_id]

    project = Assessment.find(assessment_id).project
    if !project.nil? && !project.consent_form.nil? &&
       ConsentLog.where('user_id = ? AND consent_form_id = ? AND presented = ?',
                        current_user.id, project.consent_form.id, true).empty?
      redirect_to controller: 'consent_log', action: 'edit',
                  consent_form_id: project.consent_form.id
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

      cell_value = 6000 / @members.size
      @members.each do |u|
        @factors.each do |b|
          @installment.values.build(factor: b, user: u, value: cell_value)
        end
      end

      render @project.style.filename
    end
  end

  def create
    @installment = Installment.new(i_params) # OLD code: params[:installment] )
    redirected = false

    # I need to figure out these redirects properly
    found = false
    @installment.group.users.each do |user|
      found = true if current_user == user
    end

    if !found
      redirect_to root_url error: 'You are not a member of this group and ' \
                                     'therefore are not permitted to submit this installment.'
    elsif @installment.save
      project = @installment.assessment.project
      flash[:notice] = 'Successfully saved your assessment installment.'
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
        flash[:error] = 'Your assessment installment could not be recorded'
        render @installment.assessment.project.style.filename
      end

    end
  end

  def demo_start

  end

  def demo_complete
    #TODO: Clean this up.
    assessment_id = params[:assessment_id]

    project = Assessment.find(assessment_id).project
    if !project.nil? && !project.consent_form.nil? &&
       ConsentLog.where('user_id = ? AND consent_form_id = ? AND presented = ?',
                        current_user.id, project.consent_form.id, true).empty?
      redirect_to controller: 'consent_log', action: 'edit',
                  consent_form_id: project.consent_form.id
    else

      group_id = params[:group_id]
      @group = Group.find(group_id)
      # validate that current_user is in the
      user_id = current_user.id

      @installment = Installment.includes(values: [:behaviour, :user], assessment: :project)
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

  private

  def i_params
    params. require(:installment).permit(:inst_date, :comments, :group_id, :user_id, :assessment_id, :group_id, values: [:value, :factor_id])
  end
end

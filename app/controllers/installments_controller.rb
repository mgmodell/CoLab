class InstallmentsController < ApplicationController
  def edit
    assessment_id = params[ :assessment_id ]

    project = Assessment.find( assessment_id ).project
    if !project.nil? && !project.consent_form.nil? &&
      ConsentLog.where( "user_id = ? AND consent_form_id = ? AND presented = ?",
      current_user.id, project.consent_form.id, true ).empty?
      redirect_to :controller => "consent_log", :action => "edit",
      :consent_form_id => project.consent_form.id
    else

      group_id = params[ :group_id ]
      @group = Group.find( group_id )
      #validate that current_user is in the
      user_id = current_user.id

      @installment = Installment.includes( :values => [ :behaviour, :user ], :assessment => :project ).
      where( :assessment_id=> assessment_id,
        :user_id=> user_id,
      :group_id=> group_id ).first


      #generate the values
      @project = @installment.assessment.project
      @factors = @installment.assessment.project.factors
      @project_name = @installment.assessment.project.name
      @members = @group.users

      render @project.style.filename
    end

  end

  def update
    @installment = Installment.find( params[:id])
    if @installment.update_attributes( params[:installment])
      redirect_to root_url, :notice => "Installment successfully updated"
    else
      @group = Group.find( @installment.group )
      @project = @installment.assessment.project
      @factors = @installment.assessment.project.factors
      @project_name = @installment.assessment.project.name
      @members = @group.users
      render :action => 'edit'
    end
  end

  def new
    assessment_id = params[ :assessment_id ]

    project = Assessment.find( assessment_id ).project
    if !project.nil? && !project.consent_form.nil? &&
      ConsentLog.where( "user_id = ? AND consent_form_id = ? AND presented = ?",
      current_user.id, project.consent_form.id, true ).empty?
      redirect_to :controller => "consent_log", :action => "edit",
      :consent_form_id => project.consent_form.id
    else

      group_id = params[ :group_id ]
      @group = Group.find( group_id )
      #validate that current_user is in the
      user_id = current_user.id

      @installment = Installment.new( :assessment_id=> assessment_id,
        :user_id=> user_id,
        :inst_date=> Time.now,
      :group_id=> group_id )
      #@installment.user = current_user

      #generate the values
      @project = @installment.assessment.project
      @factors = @installment.assessment.project.factors
      @project_name = @installment.assessment.project.name
      @members = @group.users
      #removed proactive build of value objects.

      cell_value = 6000 / @members.size
      @members.each do |u|
        @factors.each do |b|
          @installment.values.build( :factor => b, :user => u, :value => cell_value )
        end
      end

      render @project.style.filename
    end

  end

  def create
    @installment = Installment.new( params[:installment] )
    redirected = false

    #I need to figure out these redirects properly
    found = false
    @installment.group.users.each do |user|
      if current_user == user
        found = true
      end
    end

    if !found
      redirect_to root_url :error => "You are not a member of this group and " +
      "therefore are not permitted to submit this installment."
    elsif @installment.save
      project = @installment.assessment.project
      if project.is_for_research?
        #gfus = group_follow_up_schedule
        gfus = GroupFollowUpSchedule.where(
          :assessment_id => @installment.assessment.id,
        :group_id => @installment.group.id )
        if gfus.count < 1
          follow_up_week = false
          follow_up_count = GroupFollowUpSchedule.joins( :project ).where(
          :group_id => @installment.id ).count
          if follow_up_count < project.max_follow_ups &&
            Random.rand( 101 ) < project.follow_up_likelihood
            follow_up_week = true
          end
          gfus = GroupFollowUpSchedule.create( :follow_up_week => follow_up_week,
            :assessment_id => @installment.assessment.id,
          :group_id => @installment.group.id )
        else
          gfus = gfus[ 0 ]
        end
        if gfus.follow_up_week
          redirect_to :controller => "individual_follow_ups",
          :action => "new",
          :user_id => @installment.user.id,
          :group_follow_up_id => gfus.id,
          :project_id => project.id
          redirected = true
        end
      end
      flash[:notice] = "Successfully saved your assessment installment."
      if !redirected
        redirect_to root_url
      end
    else
      @factors = @installment.assessment.project.factors
      @project_name = @installment.assessment.project.name
      @group = @installment.group

      @members = @installment.values_by_user.keys
      if @installment.errors[:base].any?
        flash[:error] = @installment.errors[:base][ 0 ]
        redirect_to root_url
      else
        flash[:error] = "Your assessment installment could not be recorded"
        render @installment.assessment.project.style.filename
      end

    end
  end
end

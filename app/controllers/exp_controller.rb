class ExpController < ApplicationController
  def next
    experience_id = params[:experience_id]

    @experience = Experience.still_open.joins(course: { rosters: :user })
                            .where(users: { id: @current_user }).take

    if @experience.nil?
      redirect_to '/', notice: 'That Experience is a part of another course'
    else
      @reaction = @experience.get_user_reaction(@current_user)
      if @reaction.id.nil?
        @reaction.save
        render :studyInstructions
      else
        week = @reaction.next_week
        if week.nil?
          # we just finished the last week
          render :reaction
        end
        @diagnosis = Diagnosis.new(reaction: @reaction, week: week)
      end
    end
  end

  def diagnose
    # record a diagnosis
  end

  def react
    # record a reaction
  end
end

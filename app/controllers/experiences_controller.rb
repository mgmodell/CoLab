class ExperiencesController < ApplicationController
  def next
    experience_id = params[ :experience_id ]

    @experience = Experience.still_open.joins( course: { rosters: :user } ).
      where( users: { id: @current_user } ).take

    if @experience.nil?
      redirect_to "/", notice: "That Experience is a part of another course"
    else
      @reaction = @experience.get_user_reaction( @current_user )
      if @reaction.id.nil?
        @reaction.save
        render :studyInstructions
      else
        @week = @reaction.next_week
        if @week.nil?
          #we just finished the last week
          #render reaction
        else
          #render new - pretty sure I don't need this
        end
      end
    end
  end

  def diagnose
    #record a reaction
    
  end

  def reaction
    #record a reaction
  end
end

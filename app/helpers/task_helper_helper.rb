module TaskHelperHelper

  def task_link task:, anonymize:, user:
    if task.class == BingoGame
      candidate_list = task.candidate_list_for_user( user )
      if task.awaiting_review?
        o_string = link_to "Review: #{task.get_name( anonymize )}",
    review_bingo_candidates_path( task )
      elsif task.is_open?
        o_string = link_to task.get_name( anonymize ),
    edit_candidate_list_path( candidate_list )
      elsif task.reviewed
        o_string = link_to task.get_name( anonymize ), candidate_list_path(
    candidate_list )
      else
        o_string = "BingoGame: #{task.get_name( anonymize )}"
      end
    elsif task.class == Assessment
      group = task.group_for_user( user )
      if task.is_completed_by_user user
        o_string = link_to group.get_name( anonymize ),
    edit_installment_path( :assessment_id => task.id, :group_id => group.id
    )
      else
        o_string = link_to group.get_name( anonymize ),
    new_installment_path( :assessment_id => task.id, :group_id => group.id )
      end
      o_string += raw ( "<br><small>(#{t :project }:
    #{task.project.get_name( anonymize )})</small>" )
    elsif task.class == Experience
      reaction = task.get_user_reaction( user )
      if reaction.behavior.present?
        o_string = task.get_name( anonymize )
      else
        o_string = link_to task.get_name( anonymize ), next_experience_path(
    :experience_id => task.id )
      end
    else
      o_string = "Unhandled object"
    end
  end
end
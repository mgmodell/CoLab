# frozen_string_literal: true

module TaskHelperHelper
  def task_link(task:, anonymize:, user:)
    if task.instance_of?(BingoGame)
      candidate_list = task.candidate_list_for_user(user)
      if task.awaiting_review?
                   link_to t('candidate_lists.review',
                             task: task.get_name(anonymize)),
                           review_bingo_candidates_path(task)
                 elsif task.is_open?
                   link_to t('candidate_lists.enter',
                             task: task.get_name(anonymize)),
                           edit_candidate_list_path(candidate_list)
                 elsif task.reviewed
                   link_to t('candidate_lists.play',
                             task: task.get_name(anonymize)),
                           candidate_list_path(candidate_list)
                 else
                   "Bingo Game: #{task.get_name(anonymize)}"
                 end
    elsif task.instance_of?(Assessment)
      group = task.group_for_user(user)
      o_string = link_to group.get_name(anonymize),
                         edit_installment_path(assessment_id: task.id)
      o_string += raw "<br><small>(#{t :project}:
        #{task.project.get_name(anonymize)})</small>"
    elsif task.instance_of?(Experience)
      reaction = task.get_user_reaction(user)
      if reaction.behavior.present?
                   t('experiences.completed',
                     task: task.get_name(anonymize))
                 else
                   link_to I18n.t('experiences.available',
                                  task: task.get_name(anonymize)),
                           next_experience_path(experience_id: task.id)
                 end
    else
      'Unhandled object'
    end
  end
end

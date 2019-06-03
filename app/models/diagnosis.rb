# frozen_string_literal: true

class Diagnosis < ApplicationRecord
  belongs_to :behavior, inverse_of: :diagnoses
  belongs_to :reaction, inverse_of: :diagnoses
  belongs_to :week, inverse_of: :diagnoses

  has_one :user, through: :reaction

  validate :validate_other_name
  validate :validate_unique

  def validate_other_name
    if !behavior_id.nil? &&
       Behavior.find(behavior_id).name == 'Other' &&
       other_name.blank?

      errors.add(:other_name, I18n.t('diagnosis.other_name_rqrd'))
    end
  end

  def validate_unique
    if Diagnosis.where(reaction: reaction, week_id: week_id).exists?
      errors[:base] << I18n.t('diagnosis.duplicate_entry')
    end
  end
end

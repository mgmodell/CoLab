# frozen_string_literal: true

class Diagnosis < ApplicationRecord
  belongs_to :behavior, inverse_of: :diagnoses
  belongs_to :reaction, inverse_of: :diagnoses, counter_cache: true
  belongs_to :week, inverse_of: :diagnoses

  has_one :user, through: :reaction

  validate :validate_other_name
  validate :validate_unique
  validates :other_name, length: { maximum: 255 }

  def validate_other_name
    if !behavior_id.nil? &&
       'Other' == Behavior.find(behavior_id).name &&
       other_name.blank?

      errors.add(:other_name, I18n.t('diagnosis.other_name_rqrd'))
    end
  end

  def validate_unique
    errors.add(:base, I18n.t('diagnosis.duplicate_entry')) if Diagnosis.where(reaction:, week_id:).exists?
  end
end

class Assignment < ApplicationRecord
  include TimezonesSupportConcern
  include DateSanitySupportConcern

  belongs_to :rubric, inverse_of: :assignments
  belongs_to :course, inverse_of: :assignments
  belongs_to :project, optional: true

  validates :name, :end_date, :start_date, presence: true
  before_create :anonymize

  before_validation :init_dates # From DateSanitySupportConcern

  validate :submission_type

  # Validations
  validates :passing, numericality: { in: 0..100 }

  def get_description(anonymous = false)
    anonymous ? anon_description : description
  end

  def get_name(anonymous = false)
    anonymous ? anon_name : name
  end

  def get_type
    I18n.t(:assignment)
  end

  def type
    'Assignment'
  end

  def get_link
    'assignment'
  end

  private

  def submission_type
    return if self.text_sub || self.link_sub || self.file_sub

    errors.add(:submission_types, I18n.t('assignments.error.submission_type'))

  end

  def anonymize
    self.anon_name = "#{Faker::Company.profession} #{Faker::Company.industry}"
    self.anon_description = "#{Faker::Lorem.sentence(
      word_count: 8,
      supplemental: true,
      random_words_to_add: 9
    )}"
  end
end

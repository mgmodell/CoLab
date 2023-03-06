class Rubric < ApplicationRecord

    belongs_to :parent, class_name: 'Rubric', optional: true

    has_many :criteria, dependent: :destroy
    accepts_nested_attributes_for :criteria, allow_destroy: true

    before_create :anonymize

    belongs_to :school
    belongs_to :user


    before_create :set_owner
    validate :publish_logic

    def set_owner
        self.user ||= @current_user
        self.school ||= @current_user.school
    end

  private
  def anonymize
    self.anon_name = "#{Faker::Company.bs}"
    self.anon_description = "#{Faker::Lorem.sentence(
        word_count: 8,
        supplemental: true,
        random_words_to_add: 9)}"
    self.anon_version = version + (Random.rand * 11).floor
  end

  def publish_logic
    if ! self.published_was && self.published
      self.active = true
    elsif self.published_was
      unless self.changes.keys == ['active']
        errors.add(:main, 'A published rubric cannot be modified. A new version must be created.')
      end
    end
    errors
  end
end

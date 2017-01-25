class Installment < ActiveRecord::Base
  belongs_to :assessment, inverse_of: :installments
  belongs_to :user, inverse_of: :installments
  belongs_to :group, inverse_of: :installments

  has_many :values, inverse_of: :installment

  validates :inst_date, :assessment_id, :user_id, presence: true
  validate :check_dates

  before_save :normalize_sums

  def value_for_user_factor(user, factor)
    if @value_hash.nil?
      @value_hash = {}
      values.each do |v|
        @value_hash.store [v.user, v.factor], v
      end
    end
    @value_hash[[user, factor]]
  end

  def values_by_factor
    hash_hash = {}

    values.each do |v|
      au_hash = hash_hash[v.factor]
      au_hash = {} if au_hash.nil?
      au_hash.store(v.user, v)
      hash_hash.store(v.factor, au_hash)
    end
    hash_hash
  end

  def values_by_user
    hash_hash = {}
    values.each do |v|
      b_hash = hash_hash[v.user]
      b_hash = {} if b_hash.nil?
      b_hash.store(v.factor, v)
      hash_hash.store(v.user, b_hash)
    end
    hash_hash
  end

  def check_dates
    if assessment.end_date.in_time_zone.end_of_day < Time.current.in_time_zone
      errors[:base] << 'This assessment has expired and can no longer be ' \
                         "submit for this installment [expired: #{assessment.end_date.end_of_day}, now: #{Time.current}.]"
    end
    errors
  end

  def normalize_sums
    values_by_factor.each do |_factor, au_hash|
      total = au_hash.values.inject(0) { |sum, v| sum + v.value }

      au_hash.values.each do |v|
        v.value = ((6000.0 * v.value) / total).round
      end

      total = au_hash.values.inject(0) { |sum, v| sum + v.value }
      difference = 6000 - total
      if difference != 0
        delta = difference <=> 0
        index = 0
        difference.abs.times do
          au_hash.values[index].value += delta
          index += 1
        end
        total = au_hash.values.inject(0) { |sum, v| sum + v.value }
      end
      if 6000 != total
        errors[:base] << 'Unable to reconcile reported values. Please contact an administrator.'
      end
    end
  end
end

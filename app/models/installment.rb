# frozen_string_literal: true
class Installment < ActiveRecord::Base
  belongs_to :assessment, inverse_of: :installments
  belongs_to :user, inverse_of: :installments
  belongs_to :group, inverse_of: :installments

  has_many :values, inverse_of: :installment, dependent: :destroy
  accepts_nested_attributes_for :values

  validates :inst_date, :assessment_id, :user_id, presence: true
  validate :check_dates

  before_save :normalize_sums

  TOTAL_VAL = 6000.0

  # Support inclusion of comments
  def prettyComment(anonymize)
    pretty_comments = '<no comment>'
    if comments.present?
      pretty_comments = if anonymize && anon_comments.present?
                          anon_comments
                        elsif anonymize && anon_comments.blank?
                          'Comments not yet available'
                        else
                          comments
                        end
    end
    pretty_comments
  end

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

    values.includes(:factor).each do |v|
      au_hash = hash_hash[v.factor]
      au_hash = {} if au_hash.nil?
      au_hash.store(v.user, v)
      hash_hash.store(v.factor, au_hash)
    end
    hash_hash
  end

  def values_by_user
    hash_hash = {}
    values.includes(:factor).each do |v|
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

  def anonymize_comments
    working_space = comments

    # Phase 1 - convert to codes
    this_course = assessment.project.course
    this_school = this_course.school
    working_space.gsub! /#{this_school.name}/i, "[s_#{this_school.id}]"
    working_space.gsub! /#{this_course.name}/i, "[c_#{this_course.id}]"

    this_course.projects.each do |project|
      working_space.gsub! /#{project.name}/i, "[p_#{project.id}]"
      project.groups.each do |group|
        working_space.gsub! /#{group.name}/i, "[g_#{group.id}]"
      end
    end
    this_course.users.each do |user|
      working_space.gsub! /#{user.first_name}/i, "[ufn_#{user.id}]"
      working_space.gsub! /#{user.last_name}/i, "[uln_#{user.id}]"
    end
    # Phase 2 - convert from codes
    working_space.gsub! /"[s_#{this_school.id}]"/i, this_school.anon_name
    working_space.gsub! /"[c_#{this_course.id}]"/i, this_course.anon_name
    this_course.projects.each do |project|
      working_space.gsub! /"[p_#{project.id}]"/i, project.anon_name
      project.groups.each do |group|
        working_space.gsub! /"[g_#{group.id}]"/i, group.anon_name
      end
    end
    this_course.users.each do |user|
      working_space.gsub! /"[ufn_#{user.id}]"/i, user.anon_first_name
      working_space.gsub! /"[uln_#{user.id}]"/i, user.anon_last_name
    end

    self.anon_comments = working_space
    save
  end

  def normalize_sums
    values_by_factor.each do |_factor, au_hash|
      total = au_hash.values.inject(0) { |sum, v| sum + v.value }

      au_hash.values.each do |v|
        prelim = (Installment::TOTAL_VAL * v.value) / total
        if prelim.nan? 
          v.value = ( Installment::TOTAL_VAL / v.installment.values.count ).round
        else
          v.value = prelim.round
        end
      end

      total = au_hash.values.inject(0) { |sum, v| sum + v.value }
      difference = Installment::TOTAL_VAL - total
      if difference != 0
        delta = difference <=> 0
        index = 0
        difference.abs.to_i.times do
          au_hash.values[index].value += delta
          index += 1
        end
        total = au_hash.values.inject(0) { |sum, v| sum + v.value }
      end
      if Installment::TOTAL_VAL != total
        errors[:base] << 'Unable to reconcile reported values. Please contact an administrator.'
      end
    end
  end
end

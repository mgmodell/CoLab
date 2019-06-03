# frozen_string_literal: true

class Installment < ApplicationRecord
  belongs_to :assessment, inverse_of: :installments
  belongs_to :user, inverse_of: :installments
  belongs_to :group, inverse_of: :installments

  has_many :values, inverse_of: :installment, dependent: :destroy
  accepts_nested_attributes_for :values

  validates :inst_date, :user_id, presence: true
  validate :check_dates

  before_save :normalize_sums

  TOTAL_VAL = 6000.0

  # Support inclusion of comments
  def pretty_comment(anonymize)
    pretty_comments = '<no comment>'
    if comments.present?
      pretty_comments = if anonymize && anon_comments.present?
                          anon_comments
                        elsif anonymize && anon_comments.blank?
                          anonymize_comments
                          save validate: false
                          anon_comments
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

    values.includes(:factor).find_each do |v|
      au_hash = hash_hash[v.factor]
      au_hash = {} if au_hash.nil?
      au_hash.store(v.user, v)
      hash_hash.store(v.factor, au_hash)
    end
    hash_hash
  end

  def values_by_user
    hash_hash = {}
    values.includes(:factor).find_each do |v|
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
    if comments.present?
      working_space = comments.dup

      # Phase 1 - convert to codes
      this_course = Course.readonly.includes(:school, :users, projects: :users)
                          .find(assessment.project.course_id)

      this_school = this_course.school
      if this_school.name.present?
        working_space.gsub!(/\b#{this_school.name}\b/i, "[s_#{this_school.id}]")
      end
      if this_course.name.present?
        working_space.gsub!(/\b#{this_course.name}\b/i, "[cnam_#{this_course.id}]")
      end
      if this_course.number.present?
        working_space.gsub!(/\b#{this_course.number}\b/i, "[cnum_#{this_course.id}]")
      end

      this_course.projects.each do |project|
        if project.name.present?
          working_space.gsub!(/\b#{project.name}\b/i, "[p_#{project.id}]")
        end
        project.groups.each do |group|
          if group.name.present?
            working_space.gsub!(/\b#{group.name}\b/i, "[g_#{group.id}]")
          end
        end
      end

      this_course.users.each do |user|
        if user.first_name.present?
          working_space.gsub! /\b#{user.first_name}\b/i, "[ufn_#{user.id}]"
        end
        if user.last_name.present?
          working_space.gsub! /\b#{user.last_name}\b/i, "[uln_#{user.id}]"
        end
      end

      # Phase 2 - convert from codes
      working_space.gsub!("[s_#{this_school.id}]", this_school.anon_name)
      working_space.gsub!("[cnam_#{this_course.id}]", this_course.anon_name)
      working_space.gsub!("[cnum_#{this_course.id}]", this_course.anon_number)

      this_course.projects.each do |project|
        working_space.gsub!("[p_#{project.id}]", project.anon_name)
        project.groups.each do |group|
          working_space.gsub!("[g_#{group.id}]", group.anon_name)
        end
      end

      this_course.users.each do |user|
        working_space.gsub!("[ufn_#{user.id}]", user.anon_first_name)
        working_space.gsub!("[uln_#{user.id}]", user.anon_last_name)
      end

      self.anon_comments = working_space
    end
  end

  def normalize_sums
    values_by_factor.each do |_factor, au_hash|
      total = au_hash.values.inject(0) { |sum, v| sum + v.value }

      au_hash.values.each do |v|
        prelim = (Installment::TOTAL_VAL * v.value) / total
        v.value = if prelim.nan?
                    (Installment::TOTAL_VAL / v.installment.values.count).round
                  else
                    prelim.round
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

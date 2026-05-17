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
  def pretty_comment( anonymize )
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

  def values_by_factor
    hash_hash = {}

    values.includes( :factor ).find_each do | v |
      au_hash = hash_hash[v.factor]
      au_hash = {} if au_hash.nil?
      au_hash.store( v.user, v )
      hash_hash.store( v.factor, au_hash )
    end
    hash_hash
  end

  def check_dates
    if assessment.end_date.in_time_zone.end_of_day < Time.current.in_time_zone
      errors.add( :base, 'This assessment has expired and can no longer be ' \
                         "submit for this installment [expired: #{assessment.end_date.end_of_day}, now: #{Time.current}.]" )
    end
    errors
  end

  def anonymize_comments
    return if comments.blank?

    working_space = comments.dup
    safe_word_regex = ->( value ) { value.present? ? /\b#{Regexp.escape( value.to_s )}\b/i : nil }

    # Phase 1 - convert to codes
    this_course = Course.readonly.includes( :school, :users, projects: :users )
                        .find( assessment.project_course_id )

    this_school = this_course.school
    if ( school_regex = safe_word_regex.call( this_school.name ) )
      working_space.gsub!( school_regex, "[s_#{this_school.id}]" )
    end
    if ( course_name_regex = safe_word_regex.call( this_course.name ) )
      working_space.gsub!( course_name_regex, "[cnam_#{this_course.id}]" )
    end
    if ( course_number_regex = safe_word_regex.call( this_course.number ) )
      working_space.gsub!( course_number_regex, "[cnum_#{this_course.id}]" )
    end

    this_course.projects.each do | project |
      if ( project_regex = safe_word_regex.call( project.name ) )
        working_space.gsub!( project_regex, "[p_#{project.id}]" )
      end
      project.groups.each do | group |
        if ( group_regex = safe_word_regex.call( group.name ) )
          working_space.gsub!( group_regex, "[g_#{group.id}]" )
        end
      end
    end

    this_course.users.each do | user |
      if ( first_name_regex = safe_word_regex.call( user.first_name ) )
        working_space.gsub!( first_name_regex, "[ufn_#{user.id}]" )
      end
      if ( last_name_regex = safe_word_regex.call( user.last_name ) )
        working_space.gsub!( last_name_regex, "[uln_#{user.id}]" )
      end
    end

    # Phase 2 - convert from codes
    working_space.gsub!( "[s_#{this_school.id}]", this_school.anon_name )
    working_space.gsub!( "[cnam_#{this_course.id}]", this_course.anon_name )
    working_space.gsub!( "[cnum_#{this_course.id}]", this_course.anon_number )

    this_course.projects.each do | project |
      working_space.gsub!( "[p_#{project.id}]", project.anon_name )
      project.groups.each do | group |
        working_space.gsub!( "[g_#{group.id}]", group.anon_name )
      end
    end

    this_course.users.each do | user |
      working_space.gsub!( "[ufn_#{user.id}]", user.anon_first_name )
      working_space.gsub!( "[uln_#{user.id}]", user.anon_last_name )
    end

    self.anon_comments = working_space
  end

  def normalize_sums
    values_by_factor.each do | _factor, au_hash |
      total = au_hash.values.inject( 0 ) { | sum, v | sum + v.value }

      au_hash.values.each do | v |
        prelim = ( Installment::TOTAL_VAL * v.value ) / total
        v.value = if prelim.nan?
                    ( Installment::TOTAL_VAL / v.installment.values.count ).round
                  else
                    prelim.round
                  end
      end

      total = au_hash.values.inject( 0 ) { | sum, v | sum + v.value }
      difference = Installment::TOTAL_VAL - total
      if 0 != difference
        delta = difference <=> 0
        index = 0
        difference.abs.to_i.times do
          au_hash.values[index].value += delta
          index += 1
        end
        total = au_hash.values.inject( 0 ) { | sum, v | sum + v.value }
      end
      errors[:base] << I18n.t( 'err_normalize_sums' ) if Installment::TOTAL_VAL != total
    end
  end

end

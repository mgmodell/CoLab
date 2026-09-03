# frozen_string_literal: true

require 'faker'
class Group < ApplicationRecord
  around_update :update_history
  after_initialize :store_load_state

  belongs_to :project, inverse_of: :groups
  has_and_belongs_to_many :users, inverse_of: :groups,
                                  after_add: :set_dirty, after_remove: :set_dirty
  has_many :group_revisions, inverse_of: :group, dependent: :destroy
  has_many :candidate_lists, inverse_of: :group, dependent: :nullify

  has_many :installments, inverse_of: :group, dependent: :destroy

  # For Diversity calculation
  has_many :home_states, through: :users
  has_many :home_countries, through: :home_states
  has_many :cip_codes, through: :users
  has_many :genders, through: :users
  has_many :primary_languages, through: :users
  has_many :submissions, inverse_of: :group, dependent: :nullify

  validates :name, presence: true
  validate :prevent_group_movement

  before_create :anonymize

  def get_name( anonymous )
    anonymous ? anon_name : name
  end

  def calc_diversity_score
    self.diversity_score = Group.calc_diversity_score_for_group(
      users: users.includes( :gender, :primary_language,
                             :cip_code, reactions: :narrative,
                                        home_state: [:home_country] )
    )
  end

  def calc_faultline_strength
    Group.calc_faultline_strength_for_group(
      users: users.includes( :gender, :primary_language,
                             :cip_code,
                             home_state: [:home_country] )
    )
  end

  def self.calc_diversity_score_for_proposed_group( emails: )
    users = User.joins( :emails ).where( emails: { email: emails.split( /\s*,\s*/ ) } )
                .includes( :gender, :primary_language,
                           :cip_code, reactions: :narrative,
                                      home_state: [:home_country] )

    Group.calc_diversity_score_for_group users:
  end

  def self.calc_diversity_score_for_group( users: )
    ds = 0
    if users.count > 1
      state_hash = Hash.new( 0 )
      cip_hash = Hash.new( 0 )
      gender_hash = Hash.new( 0 )
      primary_lang_hash = Hash.new( 0 )
      country_hash = Hash.new( 0 )
      scenario_hash = Hash.new( 0 )
      impairment_hash = Hash.new( 0 )

      users.uniq.each do | user |
        if user.home_state.present?
          state_hash[user.home_state] += 1 unless
            true == user.home_state_no_response
          country_hash[user.home_state.home_country] += 1 unless
            true == user.home_state_home_country.no_response
        end
        cip_hash[user.cip_code] += 1 unless
            user.cip_code.nil? || user.cip_code_gov_code.zero?
        primary_lang_hash[user.primary_language] += 1 unless
            user.primary_language.nil? || '__' == user.primary_language_code
        gender_hash[user.gender] += 1 unless
            user.gender.nil? || '__' == user.gender_code
        user.reactions.each do | reaction |
          scenario_hash[reaction.narrative.member] += 1
        end
        impairments = ''
        impairments += user.impairment_visual ? 'v' : ''
        impairments += user.impairment_auditory ? 'a' : ''
        impairments += user.impairment_motor ? 'm' : ''
        impairments += user.impairment_cognitive ? 'c' : ''
        impairments += user.impairment_other ? 'o' : ''
        # if there are no impairments, set it to 'u'
        impairments += impairments.blank? ? 'u' : ''
        impairment_hash[impairments] = true
      end

      now = Date.current
      values = [].extend( DescriptiveStatistics )
      users.each do | user |
        values << now.year - user.date_of_birth.year if user.date_of_birth?
      end
      age_sd = values.empty? ? 0 : values.standard_deviation

      values.clear
      users.each do | user |
        values << now.year - user.started_school.year if user.started_school?
      end
      uni_years_sd = values.empty? ? 0 : values.standard_deviation

      ds = state_hash.keys.count +
           country_hash.keys.count +
           scenario_hash.keys.count +
           ( 2 * ( gender_hash.keys.count + cip_hash.keys.count + primary_lang_hash.keys.count ) ) +
           ( age_sd + uni_years_sd ).round +
           ( impairment_hash.keys.count > 1 ? impairment_hash.keys.count : 0 )
    end
    ds
  end

  def self.calc_faultline_strength_for_proposed_group( emails: )
    normalized_emails = emails.split( /\s*,\s*/ ).filter_map do | email |
      parsed = email.strip.downcase
      parsed.presence
    end.uniq
    return 0.0 if normalized_emails.empty?

    users = User.joins( :emails ).where( 'LOWER(emails.email) IN (?)', normalized_emails )
                .distinct
                .includes( :gender, :primary_language,
                           :cip_code,
                                      home_state: [:home_country] )

    Group.calc_faultline_strength_for_group users:
  end

  def self.calc_faultline_strength_for_group( users: )
    profiles = faultline_profiles_for users
    return 0.0 if profiles.count < 3

    distance_matrix = faultline_distance_matrix_for profiles
    clusterings = faultline_clusterings_for distance_matrix
    k_values = 2..( profiles.count - 1 )
    asw_scores = k_values.filter_map do | k |
      clusters = clusterings[k]
      next if clusters.nil?

      faultline_average_silhouette_width_for clusters, distance_matrix
    end

    [asw_scores.max || 0.0, 0.0].max.round( 4 )
  end

  private

  class << self
    private

    def faultline_profiles_for( users )
      now = Date.current
      users.map do | user |
        state = user.home_state unless user.home_state_no_response == true
        country = state&.home_country
        country = nil if country&.no_response == true

        impairments = ''
        impairments += user.impairment_visual ? 'v' : ''
        impairments += user.impairment_auditory ? 'a' : ''
        impairments += user.impairment_motor ? 'm' : ''
        impairments += user.impairment_cognitive ? 'c' : ''
        impairments += user.impairment_other ? 'o' : ''
        impairments = 'u' if impairments.blank?

        {
          categorical: {
            state: state&.id,
            country: country&.id,
            cip_code: ( user.cip_code&.gov_code&.zero? ? nil : user.cip_code&.id ),
            gender: ( user.gender_code == '__' ? nil : user.gender&.id ),
            primary_language: ( user.primary_language_code == '__' ? nil : user.primary_language&.id ),
            impairment: impairments
          },
          numeric: {
            age: user.date_of_birth? ? now.year - user.date_of_birth.year : nil,
            university_years: user.started_school? ? now.year - user.started_school.year : nil
          }
        }
      end
    end

    def faultline_distance_matrix_for( profiles )
      categorical_keys = profiles.first[:categorical].keys
      numeric_keys = profiles.first[:numeric].keys
      categorical_weights = faultline_categorical_weights_for profiles, categorical_keys
      numeric_ranges = faultline_numeric_ranges_for profiles, numeric_keys
      point_count = profiles.count

      Array.new( point_count ) do | i |
        Array.new( point_count ) do | j |
          if i == j
            0.0
          else
            faultline_distance_between_profiles(
              profile_one: profiles[i],
              profile_two: profiles[j],
              categorical_keys:,
              categorical_weights:,
              numeric_keys:,
              numeric_ranges:
            )
          end
        end
      end
    end

    def faultline_categorical_weights_for( profiles, keys )
      keys.to_h do | key |
        values = profiles.filter_map { | profile | profile[:categorical][key] }.uniq
        weight = values.count > 1 ? ( 1.0 / values.count ) : 0.0
        [key, weight]
      end
    end

    def faultline_numeric_ranges_for( profiles, keys )
      keys.to_h do | key |
        values = profiles.filter_map { | profile | profile[:numeric][key] }
        range = values.empty? ? 0.0 : ( values.max - values.min ).to_f
        [key, range]
      end
    end

    def faultline_distance_between_profiles(
      profile_one:,
      profile_two:,
      categorical_keys:,
      categorical_weights:,
      numeric_keys:,
      numeric_ranges:
    )
      distance_sum = 0.0
      weight_sum = 0.0

      categorical_keys.each do | key |
        value_one = profile_one[:categorical][key]
        value_two = profile_two[:categorical][key]
        next if value_one.nil? || value_two.nil?

        weight = categorical_weights[key]
        next if weight.zero?

        distance_sum += ( value_one == value_two ? 0.0 : 1.0 ) * weight
        weight_sum += weight
      end

      numeric_keys.each do | key |
        value_one = profile_one[:numeric][key]
        value_two = profile_two[:numeric][key]
        next if value_one.nil? || value_two.nil?

        range = numeric_ranges[key]
        next if range.zero?

        distance_sum += ( value_one - value_two ).abs / range
        weight_sum += 1.0
      end

      return 0.0 if weight_sum.zero?

      distance_sum / weight_sum
    end

    def faultline_clusterings_for( distance_matrix )
      clusters = distance_matrix.each_index.map { | i | [i] }
      clusterings = { clusters.count => clusters.map( &:dup ) }

      while clusters.count > 1
        left_cluster, right_cluster = faultline_closest_clusters_for clusters, distance_matrix
        merged_cluster = left_cluster + right_cluster
        clusters = ( clusters - [left_cluster, right_cluster] ) << merged_cluster
        clusterings[clusters.count] = clusters.map( &:dup )
      end

      clusterings
    end

    def faultline_closest_clusters_for( clusters, distance_matrix )
      best_pair = [clusters[0], clusters[1]]
      best_distance = faultline_average_linkage_distance_for best_pair[0], best_pair[1], distance_matrix

      clusters.combination( 2 ) do | first_cluster, second_cluster |
        distance = faultline_average_linkage_distance_for first_cluster, second_cluster, distance_matrix
        next unless distance < best_distance

        best_distance = distance
        best_pair = [first_cluster, second_cluster]
      end

      best_pair
    end

    def faultline_average_linkage_distance_for( cluster_one, cluster_two, distance_matrix )
      total_distance = 0.0
      pair_count = 0

      cluster_one.each do | point_one |
        cluster_two.each do | point_two |
          total_distance += distance_matrix[point_one][point_two]
          pair_count += 1
        end
      end

      total_distance / pair_count
    end

    def faultline_average_silhouette_width_for( clusters, distance_matrix )
      cluster_map = {}
      clusters.each_with_index do | cluster, cluster_index |
        cluster.each { | point | cluster_map[point] = cluster_index }
      end

      silhouette_values = distance_matrix.each_index.map do | point_index |
        current_cluster = clusters[cluster_map[point_index]]
        faultline_silhouette_for_point point_index, current_cluster, clusters, distance_matrix
      end

      silhouette_values.sum / silhouette_values.count
    end

    def faultline_silhouette_for_point( point_index, current_cluster, clusters, distance_matrix )
      return 0.0 if current_cluster.count <= 1

      within_cluster = current_cluster - [point_index]
      a_value = faultline_average_distance_for point_index, within_cluster, distance_matrix
      b_value = clusters.reject { | cluster | cluster.equal?( current_cluster ) }
                        .map { | cluster | faultline_average_distance_for point_index, cluster, distance_matrix }
                        .min

      denominator = [a_value, b_value].max
      return 0.0 if denominator.zero?

      ( b_value - a_value ) / denominator
    end

    def faultline_average_distance_for( point_index, other_points, distance_matrix )
      return 0.0 if other_points.empty?

      other_points.sum { | other_point | distance_matrix[point_index][other_point] }.to_f / other_points.count
    end
  end

  def store_load_state
    @initial_member_state = ''
    user_ids.sort.each do | user_id |
      @initial_member_state += "#{user_id} "
    end
  end

  # Maintain a history of what has changed
  def update_history
    member_string = ''
    user_ids.sort.each do | user_id |
      member_string += "#{user_id} "
    end
    if changed? || @initial_member_state != member_string
      gr = group_revisions.new( name: name_was, group: self, members: member_string )
      calc_diversity_score if @initial_member_state != gr.members
    end

    # i_changed = (changed? || @initial_member_state != gr.members)

    yield # Do that save thing

    # gr.save if persisted? && i_changed
  end

  def prevent_group_movement
    if persisted? && project_id_was != project_id
      errors.add( :project,
                  'It is not possible to move a group from one project to another.' )
    end
    return
  end

  def set_dirty( _user )
    @dirty = true
  end

  def anonymize
    return unless anon_name.blank?

    nation_descriptor = Faker::Boolean.boolean ? Faker::Nation.language : Faker::Nation.nationality
    self.anon_name = "#{nation_descriptor} #{Faker::Company.name}s"
  end
end

# frozen_string_literal: true

require 'set'

class ProjectStudentProgressReport
  def initialize( project:, anonymize: )
    @project = project
    @anonymize = anonymize
  end

  def assessment
    # Show the active assessment when available, otherwise retain the latest completed period.
    @assessment ||= @project.assessments.active_at( Time.current ).order( :start_date, :id ).last ||
                    @project.assessments.order( :start_date, :id ).last
  end

  def call
    factors = @project.factors.order( :id ).to_a
    assessments = @project.assessments.order( :start_date, :id ).to_a
    values_by_group_assessment = Hash.new { | hash, key | hash[key] = [] }

    if assessments.any?
      Value.joins( :installment ).includes( :installment )
           .where( installments: { assessment_id: assessments.map( &:id ) } )
           .order( :id ).each do | value |
        installment = value.installment
        values_by_group_assessment[[installment.group_id, installment.assessment_id]] << value
      end
    end

    @project.groups.includes( :users ).order( :id ).map do | group |
      members = group.users.sort_by { | user | user.name( @anonymize ) }
      period_results = group_period_results(
        group:, members:, factors:, assessments:, values_by_group_assessment:
      )
      group_behaviors = group_behavior_metrics( period_results, factors )
      overall_trend = trend_points( period_results ) { | period | period[:overall_agreement] }

      {
        id: group.id,
        name: group.get_name( @anonymize ),
        overall_agreement: average_percentage( overall_trend.map { | item | item[:agreement] } ),
        week_overall_agreement: period_overall_metric( period_results ),
        overall_trend: self.class.trend_slope( overall_trend ),
        behaviors: group_behaviors,
        members: members.map do | member |
          member_reporting( member, period_results, factors )
        end
      }
    end
  end

  def self.trend_slope( points )
    return if points.size < 2

    # Fit agreement against elapsed weeks; fewer than two assessments cannot define a slope.
    start_date = Date.iso8601( points.first[:date] )
    weeks = points.map { | point | ( Date.iso8601( point[:date] ) - start_date ).to_f / 7 }
    average_week = weeks.sum / weeks.size
    agreements = points.map { | point | point[:agreement] }
    average_agreement = agreements.sum.to_f / agreements.size
    denominator = weeks.sum { | week | ( week - average_week )**2 }
    return if denominator.zero?

    numerator = weeks.zip( agreements ).sum do | week, agreement |
      ( week - average_week ) * ( agreement - average_agreement )
    end
    ( numerator / denominator ).round( 2 )
  end

  private

  def group_period_results( group:, members:, factors:, assessments:, values_by_group_assessment: )
    member_ids = members.map( &:id ).to_set
    assessments.map do | assessment |
      ratings = Hash.new { | hash, key | hash[key] = {} }
      values_by_group_assessment[[group.id, assessment.id]].each do | value |
        next unless member_ids.include?( value.user_id )

        ratings[[value.user_id, value.factor_id]][value.installment.user_id] = value.value
      end

      individuals = members.to_h do | member |
        behavior_metrics = factors.map do | factor |
          factor_ratings = ratings[[member.id, factor.id]].values
          {
            factor_id: factor.id,
            name: factor.name,
            agreement: agreement_percentage( factor_ratings ),
            contribution: factor_ratings.empty? ? nil : factor_ratings.sum.to_f / factor_ratings.size
          }
        end
        behavior_metrics_by_factor = behavior_metrics.index_by { | metric | metric[:factor_id] }
        [
          member.id,
          {
            behaviors: behavior_metrics,
            behavior_metrics_by_factor:,
            overall_agreement: average_percentage( behavior_metrics.map { | metric | metric[:agreement] } )
          }
        ]
      end

      group_behaviors = factors.map do | factor |
        {
          factor_id: factor.id,
          name: factor.name,
          agreement: average_percentage(
            individuals.values.map do | individual |
              individual[:behavior_metrics_by_factor][factor.id][:agreement]
            end
          )
        }
      end
      {
        assessment_id: assessment.id,
        date: assessment.start_date.to_date.iso8601,
        individuals:,
        behaviors: group_behaviors,
        behavior_metrics_by_factor: group_behaviors.index_by { | metric | metric[:factor_id] },
        overall_agreement: average_percentage( group_behaviors.map { | metric | metric[:agreement] } )
      }
    end
  end

  def group_behavior_metrics( period_results, factors )
    factors.map do | factor |
      trends = trend_points( period_results ) do | period |
        period[:behavior_metrics_by_factor][factor.id][:agreement]
      end
      {
        factor_id: factor.id,
        name: factor.name,
        agreement: average_percentage( trends.map { | item | item[:agreement] } ),
        week_agreement: period_metric( period_results, factor.id ),
        trend: self.class.trend_slope( trends )
      }
    end
  end

  def member_reporting( member, period_results, factors )
    member_periods = period_results.filter_map do | period |
      metric = period[:individuals][member.id]
      { date: period[:date], metric: } if metric
    end
    week_metric = current_period_individual( period_results, member.id )
    member_behaviors = factors.map do | factor |
      trends = trend_points( member_periods ) do | period |
        period[:metric][:behavior_metrics_by_factor][factor.id][:agreement]
      end
      contributions = member_periods.filter_map do | period |
        period[:metric][:behavior_metrics_by_factor][factor.id][:contribution]
      end
      week_behavior = week_metric&.dig( :behavior_metrics_by_factor, factor.id )
      {
        factor_id: factor.id,
        name: factor.name,
        agreement: average_percentage( trends.map { | item | item[:agreement] } ),
        week_agreement: week_behavior&.dig( :agreement ),
        trend: self.class.trend_slope( trends ),
        contribution: contributions.empty? ? nil : contributions.sum / contributions.size,
        week_contribution: week_behavior&.dig( :contribution )
      }
    end
    member_overall_trend = trend_points( member_periods ) { | period | period[:metric][:overall_agreement] }

    {
      id: member.id,
      name: member.name( @anonymize ),
      overall_agreement: average_percentage( member_overall_trend.map { | item | item[:agreement] } ),
      week_overall_agreement: week_metric&.dig( :overall_agreement ),
      overall_trend: self.class.trend_slope( member_overall_trend ),
      behaviors: member_behaviors,
      highest_contribution: highest_contribution( member_behaviors, :contribution ),
      week_highest_contribution: highest_contribution( member_behaviors, :week_contribution )
    }
  end

  def agreement_percentage( ratings )
    return if ratings.size < 2

    # Convert the mean pairwise absolute rating difference into agreement on a 0–100 scale.
    differences = ratings.combination( 2 ).map { | left, right | ( left - right ).abs }
    ( 100 * ( 1 - differences.sum.to_f / differences.size / Installment::TOTAL_VAL ) ).round( 1 )
  end

  def average_percentage( values )
    values = values.compact
    values.empty? ? nil : ( values.sum.to_f / values.size ).round( 1 )
  end

  def trend_points( periods )
    periods.filter_map do | period |
      agreement = yield period
      { date: period[:date], agreement: } if agreement
    end
  end

  def period_metric( periods, factor_id )
    current_period = periods.find { | period | period[:assessment_id] == assessment&.id }
    current_period&.dig( :behaviors )&.find { | metric | metric[:factor_id] == factor_id }&.dig( :agreement )
  end

  def period_overall_metric( periods )
    periods.find { | period | period[:assessment_id] == assessment&.id }&.dig( :overall_agreement )
  end

  def current_period_individual( periods, member_id )
    periods.find { | period | period[:assessment_id] == assessment&.id }&.dig( :individuals, member_id )
  end

  def highest_contribution( behaviors, field )
    behavior = behaviors.select { | metric | metric[field] }.max_by { | metric | [metric[field], -metric[:factor_id]] }
    behavior&.slice( :name, field )
  end
end

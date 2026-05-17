# frozen_string_literal: true

require 'test_helper'
require 'action_cable/testing'

class InstallmentTest < ActiveSupport::TestCase
  # ------------------------------------------------------------------
  # after_save_commit broadcasts to InstallmentChannel
  # ------------------------------------------------------------------

  test 'saving an installment broadcasts to the group channel' do
    # Use Faker-free inline helpers so the test is self-contained
    school   = School.find( 1 )
    course   = school.courses.create!(
      name:       'Test Course',
      number:     999,
      timezone:   'UTC',
      start_date: 4.months.ago,
      end_date:   2.months.from_now
    )

    project = course.projects.create!(
      name:      'Test Project',
      start_dow: 1,
      end_dow:   2,
      style:     Style.find( 2 )
    )

    group = project.groups.create!( name: 'Test Group' )

    user = User.new(
      first_name:            'Alice',
      last_name:             'Tester',
      password:              'password',
      password_confirmation: 'password',
      email:                 "alice_#{SecureRandom.hex( 4 )}@example.com",
      timezone:              'UTC',
      school:
    )
    user.skip_confirmation!
    user.save!

    group.users << user
    course.rosters.create!(
      user:,
      role: Roster.roles[:enrolled_student]
    )

    project.activate!

    assessment = Assessment.where( project: ).first
    assert_not_nil assessment, 'Project activation should create an assessment'

    factor_pack = FactorPack.create!( name: 'Test Pack', description: 'Pack for tests' )
    factor_pack.factors.create!( name: 'Effort', description: 'Effort factor' )
    project.update!( factor_pack: )
    project.reload

    cell_value = Installment::TOTAL_VAL / group.users.size

    installment = Installment.new(
      assessment:,
      user:,
      group:,
      inst_date: Time.current
    )
    group.users.each do | u |
      project.factors.each do | b |
        installment.values.build( factor: b, user: u, value: cell_value )
      end
    end

    channel = InstallmentChannel.channel_name( assessment.id, group.id )

    assert_broadcasts( channel, 1 ) do
      installment.save!
    end
  end

  test 'broadcast payload matches the saved installment data' do
    school   = School.find( 1 )
    course   = school.courses.create!(
      name:       'Broadcast Test Course',
      number:     998,
      timezone:   'UTC',
      start_date: 4.months.ago,
      end_date:   2.months.from_now
    )

    project = course.projects.create!(
      name:      'Broadcast Test Project',
      start_dow: 1,
      end_dow:   2,
      style:     Style.find( 2 )
    )

    group = project.groups.create!( name: 'Broadcast Group' )

    user = User.new(
      first_name:            'Bob',
      last_name:             'Broadcaster',
      password:              'password',
      password_confirmation: 'password',
      email:                 "bob_#{SecureRandom.hex( 4 )}@example.com",
      timezone:              'UTC',
      school:
    )
    user.skip_confirmation!
    user.save!

    group.users << user
    course.rosters.create!(
      user:,
      role: Roster.roles[:enrolled_student]
    )

    project.activate!

    assessment = Assessment.where( project: ).first

    factor_pack = FactorPack.create!( name: 'Broadcast Pack', description: 'Pack' )
    factor_pack.factors.create!( name: 'Quality', description: 'Quality factor' )
    project.update!( factor_pack: )
    project.reload

    cell_value = Installment::TOTAL_VAL / group.users.size

    installment = Installment.new(
      assessment:,
      user:,
      group:,
      inst_date: Time.current
    )
    project.factors.each do | b |
      group.users.each do | u |
        installment.values.build( factor: b, user: u, value: cell_value )
      end
    end

    channel = InstallmentChannel.channel_name( assessment.id, group.id )

    installment.save!

    transmissions = broadcasts( channel )
    assert_equal 1, transmissions.size

    payload = JSON.parse( transmissions.first )
    assert_equal 'installment_saved', payload['event']
    assert_equal user.id,             payload['user_id']
    assert_equal user.name( false ),  payload['user_name']
    assert_equal assessment.id,       payload['assessment_id']
    assert_equal group.id,            payload['group_id']
  end

  test 'normalize_sums handles zero-total factor values without nil errors' do
    installment = Installment.new
    placeholder_values = Array.new( 50 ) { Object.new }
    factor_installment = Struct.new( :values ).new( placeholder_values )
    value_struct = Struct.new( :value, :installment )
    factor_values = [
      value_struct.new( 0.0, factor_installment ),
      value_struct.new( 0.0, factor_installment )
    ]

    installment.singleton_class.define_method( :values_by_factor ) do
      { :factor_a => { :user_a => factor_values[0], :user_b => factor_values[1] } }
    end

    assert_nothing_raised { installment.normalize_sums }
    assert_equal Installment::TOTAL_VAL, factor_values.sum( &:value )
  end
end

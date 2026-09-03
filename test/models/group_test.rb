# frozen_string_literal: true

require 'test_helper'
require 'ostruct'

class GroupTest < ActiveSupport::TestCase
  test 'faultline strength is zero for groups with fewer than three users' do
    users = [
      faultline_user( group: :a ),
      faultline_user( group: :a )
    ]

    assert_equal 0.0, Group.calc_faultline_strength_for_group( users: )
  end

  test 'faultline strength is higher for aligned subgroups than homogeneous groups' do
    homogeneous_users = [
      faultline_user( group: :a ),
      faultline_user( group: :a ),
      faultline_user( group: :a ),
      faultline_user( group: :a )
    ]
    polarized_users = [
      faultline_user( group: :a ),
      faultline_user( group: :a ),
      faultline_user( group: :b ),
      faultline_user( group: :b )
    ]

    homogeneous_strength = Group.calc_faultline_strength_for_group( users: homogeneous_users )
    polarized_strength = Group.calc_faultline_strength_for_group( users: polarized_users )

    assert_in_delta 0.0, homogeneous_strength, 0.0001
    assert_operator polarized_strength, :>, homogeneous_strength
    assert_operator polarized_strength, :>=, 0.25
  end

  test 'proposed-group faultline strength deduplicates users by email join' do
    relation = MockFaultlineUserRelation.new
    captured_users = nil

    User.stub :joins, relation do
      Group.stub :calc_faultline_strength_for_group, ->( users: ) { captured_users = users; 0.42 } do
        result = Group.calc_faultline_strength_for_proposed_group(
          emails: ' A@example.com, a@example.com,  , B@example.com '
        )

        assert_equal 0.42, result
      end
    end

    assert_equal 'LOWER(emails.email) IN (?)', relation.where_clause
    assert_equal %w[a@example.com b@example.com], relation.where_emails
    assert relation.distinct_called
    assert_same relation, captured_users
  end

  test 'proposed-group faultline strength returns zero when no valid emails are provided' do
    assert_equal 0.0, Group.calc_faultline_strength_for_proposed_group( emails: '  ,   , ' )
  end

  private

  class MockFaultlineUserRelation
    attr_reader :distinct_called, :where_clause, :where_emails

    def where( clause, emails )
      @where_clause = clause
      @where_emails = emails
      self
    end

    def distinct
      @distinct_called = true
      self
    end

    def includes( *_args )
      self
    end
  end

  def faultline_user( group: )
    country_id = ( group == :a ? 1 : 2 )
    state_id = ( group == :a ? 11 : 22 )
    gender_id = ( group == :a ? 101 : 202 )
    language_id = ( group == :a ? 301 : 302 )
    cip_id = ( group == :a ? 401 : 402 )
    cip_gov_code = ( group == :a ? 11_0101 : 26_0101 )
    started_school_year = ( group == :a ? 2023 : 2018 )
    birth_year = ( group == :a ? 2004 : 1997 )

    OpenStruct.new(
      home_state: OpenStruct.new(
        id: state_id,
        home_country: OpenStruct.new( id: country_id, no_response: false )
      ),
      home_state_no_response: false,
      cip_code: OpenStruct.new( id: cip_id, gov_code: cip_gov_code ),
      gender: OpenStruct.new( id: gender_id ),
      gender_code: ( group == :a ? 'M' : 'F' ),
      primary_language: OpenStruct.new( id: language_id ),
      primary_language_code: ( group == :a ? 'en' : 'fr' ),
      impairment_visual: ( group == :b ),
      impairment_auditory: false,
      impairment_motor: false,
      impairment_cognitive: false,
      impairment_other: false,
      date_of_birth: Date.new( birth_year, 1, 1 ),
      started_school: Date.new( started_school_year, 1, 1 ),
      date_of_birth?: true,
      started_school?: true
    )
  end
end

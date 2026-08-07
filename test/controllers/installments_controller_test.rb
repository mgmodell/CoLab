# frozen_string_literal: true

require 'test_helper'

class InstallmentsControllerTest < ActionController::TestCase
  setup do
    @user = User.new
    @user.id = 1

    @factor = Factor.new( name: 'Test Factor', description: 'A test factor' )
    @factor.id = 10

    @project = Project.new( name: 'Test Project' )
    @project.id = 3

    @assessment = Assessment.new
    @assessment.id = 7

    @group = Group.new( name: 'Test Group' )
    @group.id = 2

    @installment = Installment.new
    @installment.id = 42

    # Capture into local variables so that define_singleton_method blocks
    # reference the right objects regardless of how self changes at call time.
    _factor   = @factor
    _project  = @project
    _assess   = @assessment
    _group    = @group
    _user     = @user

    @project.define_singleton_method( :factors ) { [ _factor ] }
    @project.define_singleton_method( :description ) { 'Desc' }

    @assessment.define_singleton_method( :project ) { _project }
    @assessment.define_singleton_method( :end_date ) { 1.week.from_now }

    @group.define_singleton_method( :users ) { [ _user ] }

    @installment.define_singleton_method( :assessment )    { _assess }
    @installment.define_singleton_method( :group )         { _group }
    @installment.define_singleton_method( :group_id )      { _group.id }
    @installment.define_singleton_method( :assessment_id ) { _assess.id }
    @installment.define_singleton_method( :inst_date )     { Time.current }
    @installment.define_singleton_method( :reload )        { self }
    @installment.define_singleton_method( :errors )        { ActiveModel::Errors.new( Installment.new ) }
  end

  # --- create: success path ---

  test 'create returns JSON with installment key on success' do
    values_collection = Minitest::Mock.new
    values_collection.expect( :as_json, [], [ Hash ] )

    _values = values_collection
    @installment.define_singleton_method( :values ) { _values }

    Installment.stub( :new, @installment ) do
      @installment.stub( :save!, true ) do
        @controller.stub( :authenticate_user!, nil ) do
          @controller.stub( :current_user, @user ) do
            post :create,
                 params: {
                   installment: {
                     assessment_id: @assessment.id,
                     group_id:      @group.id,
                     inst_date:     Time.current.iso8601,
                     comments:      ''
                   },
                   contributions: {}
                 },
                 format: :json
            assert_response :success
            json = JSON.parse( response.body )
            assert json.key?( 'installment' ), 'Response should include an installment key'
            assert json.key?( 'factors' ),     'Response should include a factors key'
            assert json.key?( 'group' ),       'Response should include a group key'
            assert_equal @group.id, json['installment']['group_id'],
                         'installment should include group_id'
            assert_equal false, json['messages']['error'],
                         'Response should not indicate an error'
            values_collection.verify
          end
        end
      end
    end
  end

  # --- create: RecordInvalid error path ---

  test 'create returns error JSON when installment is invalid' do
    invalid_installment = Installment.new
    error = ActiveRecord::RecordInvalid.new( invalid_installment )

    Installment.stub( :new, invalid_installment ) do
      invalid_installment.stub( :save!, ->() { raise error } ) do
        @controller.stub( :authenticate_user!, nil ) do
          @controller.stub( :current_user, @user ) do
            post :create,
                 params: {
                   installment: {
                     assessment_id: nil,
                     group_id:      nil,
                     inst_date:     nil,
                     comments:      ''
                   },
                   contributions: {}
                 },
                 format: :json
            assert_response :success
            json = JSON.parse( response.body )
            assert json['error'],                       'Response should indicate an error'
            assert_equal 'installment_invalid', json['messages']['error_type']
          end
        end
      end
    end
  end
end

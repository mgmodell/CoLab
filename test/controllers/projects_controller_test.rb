# frozen_string_literal: true

require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase
  setup do
    # Build a minimal data hierarchy for testing groups.
    # We create objects directly so the tests do not depend on the
    # pre-existing fixture state of unrelated tables.
    @school = School.create!( name: 'Test School' )
    @course = Course.create!(
      name: 'Test Course',
      school: @school,
      timezone: 'UTC',
      start_date: 1.month.ago,
      end_date: 1.month.from_now
    )
    # Traco stores translations in *_en / *_ko columns on the same table.
    @style = Style.create!( name_en: 'Test Style', filename: 'test.css' )
    @project = Project.create!(
      name: 'Test Project',
      description: 'A test project',
      course: @course,
      style: @style,
      start_dow: 1,
      end_dow: 5
    )
    @group = Group.create!( name: 'Original Name', project: @project )

    # Bypass DeviseTokenAuth authentication – set_groups itself does not
    # require current_user; we only need authenticate_user! to be a no-op
    # and user_signed_in? to return false so switch_locale falls back to
    # the default locale.
    @controller.define_singleton_method( :authenticate_user! ) { nil }
    @controller.define_singleton_method( :user_signed_in? ) { false }
  end

  # -----------------------------------------------------------------------
  # set_groups (PATCH projects/groups/:id)
  # -----------------------------------------------------------------------

  test 'set_groups returns the updated group name in the response' do
    new_name = 'Updated Group Name'

    patch :set_groups, params: {
      id: @project.id,
      groups: { @group.id.to_s => { id: @group.id, name: new_name } },
      students: {}
    }, format: :json

    assert_response :success
    data = JSON.parse( response.body )
    returned_names = data['groups'].values.map { | g | g['name'] }

    assert_includes returned_names, new_name,
                    'Response must include the updated group name'
    assert_not_includes returned_names, 'Original Name',
                        'Response must not include the stale (pre-save) group name'
  end

  test 'set_groups persists the updated group name to the database' do
    new_name = 'Persisted Group Name'

    patch :set_groups, params: {
      id: @project.id,
      groups: { @group.id.to_s => { id: @group.id, name: new_name } },
      students: {}
    }, format: :json

    assert_response :success
    assert_equal new_name, @group.reload.name
  end

  # -----------------------------------------------------------------------
  # get_groups (GET projects/groups/:id)
  # -----------------------------------------------------------------------

  test 'get_groups returns existing groups for a project' do
    get :get_groups, params: { id: @project.id }, format: :json

    assert_response :success
    data = JSON.parse( response.body )
    returned_names = data['groups'].values.map { | g | g['name'] }
    assert_includes returned_names, @group.name
  end
end

# frozen_string_literal: true

module InstructorStudentProgressAssertions
  def assert_instructor_progress( activity, activity_type, progress_detail, completed_count = 0 )
    activity_name = activity.respond_to?( :name ) ? activity.name : activity.get_name( false )
    total_students = student_count
    completion_percent = total_students.zero? ? 0 : 100 * completed_count / total_students
    wait_for_render
    row = find( :xpath, "//tr[td[contains(.,#{xpath_literal( activity_name )})]]" )
    row.text.should include( "#{completion_percent}% complete (#{completed_count}/#{total_students})" )
    row.click
    wait_for_render
    page.current_path.should eq "/admin/courses/#{@course.id}/#{activity_type}/#{activity.id}"

    find( :xpath, "//li[@role='tab' and contains(.,'Student progress')]" ).click
    wait_for_render
    page.should have_content( "#{completion_percent}% complete (#{completed_count} of #{total_students} students)" )
    page.should have_content( completed_count.positive? ? 'Complete' : 'Incomplete' )
    page.should have_content( progress_detail )
    page.all( :xpath, "//tbody/tr[@role='row']" ).size.should eq total_students
  end

  def student_count
    @course.rosters.enrolled_student.count
  end
end

World( InstructorStudentProgressAssertions )

Then 'the instructor sees the experience and its student progress' do
  assert_instructor_progress( @experience, 'experience', '0%' )
end

Given( 'the course has an open {string} activity for progress' ) do | activity_type |
  start_date = 1.day.ago
  end_date = 2.months.from_now

  case activity_type
  when 'assignment'
    @progress_activity = @course.assignments.create!(
      name: 'Progress Assignment',
      start_date:,
      end_date:,
      text_sub: true
    )
    @progress_activity.update_column( :active, true )
  when 'bingo_game'
    @progress_activity = @course.bingo_games.create!(
      topic: 'Progress Bingo',
      source: 'Cucumber progress test',
      group_option: false,
      individual_count: 4,
      group_discount: 0,
      start_date:,
      end_date:,
      lead_time: 2
    )
    @progress_activity.update_column( :active, true )
  when 'project'
    current_weekday = Time.current.in_time_zone( @course.timezone ).wday
    @progress_activity = @course.projects.create!(
      name: 'Progress Project',
      start_date:,
      end_date:,
      start_dow: current_weekday,
      end_dow: current_weekday,
      style: Style.find( 2 )
    )
    @progress_activity.update_column( :active, true )
  else
    raise "Unknown activity type: #{activity_type}"
  end
end

Then( 'the instructor sees student progress for the {string} activity' ) do | activity_type |
  progress_detail = {
    'assignment' => 'No submission',
    'bingo_game' => '0%',
    'project' => 'No check-in'
  }.fetch( activity_type )
  assert_instructor_progress( @progress_activity, activity_type, progress_detail )
end

Given( 'one student has completed the progress assignment' ) do
  rubric = Rubric.create!(
    name: 'Progress Rubric',
    description: 'Progress test rubric',
    school: @user.school,
    user: @user
  )
  rubric.criteria.create!(
    description: 'Criterion',
    sequence: 1,
    l1_description: 'Beginning'
  )
  @progress_activity.update!( rubric: )
  student = @users.first
  @progress_activity.submissions.create!(
    submitted: Time.current,
    sub_text: '<p>Submitted work</p>',
    user: student,
    creator: student,
    rubric:
  )
end

Then( 'the instructor sees {int} completed student for the {string} activity' ) do | completed_count, activity_type |
  assert_instructor_progress(
    @progress_activity,
    activity_type,
    "#{completed_count} submission",
    completed_count
  )
end

# frozen_string_literal: true

require 'test_helper'

class ProjectStudentProgressReportTest < ActiveSupport::TestCase
  test 'agreement trend slope is nil without multiple assessments' do
    assert_nil ProjectStudentProgressReport.trend_slope( [{ date: '2026-10-01', agreement: 100.0 }] )
  end

  test 'agreement trend slope is nil when assessment dates are identical' do
    points = [
      { date: '2026-10-01', agreement: 0.0 },
      { date: '2026-10-01', agreement: 100.0 }
    ]

    assert_nil ProjectStudentProgressReport.trend_slope( points )
  end

  test 'agreement trend slope measures percentage points per week with irregular dates' do
    points = [
      { date: '2026-10-01', agreement: 0.0 },
      { date: '2026-10-04', agreement: 30.0 },
      { date: '2026-10-11', agreement: 100.0 }
    ]

    assert_equal 100.0, ProjectStudentProgressReport.trend_slope( points )
  end

  test 'agreement trend slope supports a negative trend' do
    points = [
      { date: '2026-10-01', agreement: 100.0 },
      { date: '2026-10-08', agreement: 0.0 }
    ]

    assert_equal(-100.0, ProjectStudentProgressReport.trend_slope( points ))
  end
end

# frozen_string_literal: true

require 'test_helper'

class HomeControllerReportingTest < ActiveSupport::TestCase
  test 'agreement trend slope is nil without multiple assessments' do
    points = [{ date: '2026-10-01', agreement: 100.0 }]

    assert_nil HomeController.new.send( :agreement_trend_slope, points )
  end

  test 'agreement trend slope measures percentage points per week' do
    points = [
      { date: '2026-10-01', agreement: 0.0 },
      { date: '2026-10-08', agreement: 100.0 }
    ]

    assert_equal 100.0, HomeController.new.send( :agreement_trend_slope, points )
  end
end

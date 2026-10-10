# frozen_string_literal: true

Given( /^a reaction started (\d+) minutes ago with diagnoses after (\d+), (\d+) and (\d+) minutes and reaction after (\d+) minutes$/ ) do | ago, d1, d2, d3, react |
  start = ago.to_i.minutes.ago
  user = @course.rosters.students.first.user
  @reaction = Reaction.new( user:, experience: @experience,
                            narrative: Narrative.first,
                            created_at: start, updated_at: start )
  @reaction.save!( validate: false )
  [d1, d2, d3].each_with_index do | minutes, index |
    diagnosis = Diagnosis.new( reaction: @reaction, behavior: Behavior.first,
                               week: Week.where( narrative: @reaction.narrative ).order( :week_num ).offset( index ).first || Week.offset( index ).first,
                               created_at: start + minutes.to_i.minutes,
                               updated_at: start + minutes.to_i.minutes )
    diagnosis.save!( validate: false )
  end
  @reaction.reload
  @reaction.behavior = Behavior.first
  @reaction.improvements = 'Better teamwork'
  @reaction.updated_at = start + react.to_i.minutes
  @reaction.save!( touch: false )
end

Given( /^an incomplete reaction with no diagnoses$/ ) do
  user = @course.rosters.students.first.user
  @reaction = Reaction.new( user:, experience: @experience, narrative: Narrative.first )
  @reaction.save!( validate: false )
end

Then( /^the reaction timing stats show a total time of (\d+) seconds$/ ) do | seconds |
  @reaction.timing_stats[:total_time].should eq seconds.to_i
end

Then( /^the reaction timing stats show an average diagnosis time of (\d+) seconds$/ ) do | seconds |
  @reaction.timing_stats[:avg_diagnosis_time].should eq seconds.to_i
end

Then( /^the reaction timing stats show a diagnosis time standard deviation of (\d+) seconds$/ ) do | seconds |
  @reaction.timing_stats[:std_dev_diagnosis_time].should eq seconds.to_i
end

Then( /^the reaction timing stats show a reaction time of (\d+) seconds$/ ) do | seconds |
  @reaction.timing_stats[:reaction_time].should eq seconds.to_i
end

Then( /^the reaction timing stats show no times$/ ) do
  @reaction.timing_stats.each_value do | value |
    value.should be_nil
  end
end

Then( 'the results row for the reaction shows these times' ) do | table |
  wait_for_render
  row = find( :xpath, "//tbody/tr[.//a[@href='mailto:#{@reaction.user.email}']]", wait: 10 )
  headers = all( :xpath, '//thead/tr/th' ).map { | th | th.text.strip }
  cells = row.all( :xpath, './td' ).map { | td | td.text.strip }
  table.hashes.first.each do | header, expected |
    index = headers.index { | h | h.start_with?( header ) }
    index.should_not be_nil, "Column '#{header}' not found in #{headers}"
    cells[index].should eq expected
  end
end

# frozen_string_literal: true

Given( 'there are {int} {string} rubrics starting with {string}' ) do | count, is_published, prefix |
  school = School.find( 1 )
  count.times do | index |
    rubric = school.rubrics.new(
      name: "#{prefix} #{index}",
      description: Faker::GreekPhilosophers.quote,
      published: 'published' == is_published,
      user: @user
    )
    rubric.criteria.new(
      description: Faker::Company.industry,
      sequence: 1,
      l1_description: Faker::Company.bs
    )
    rubric.save
    log rubric.errors.full_messages if rubric.errors.present?
  end
end

Given( 'the user has one {string} rubric named {string}' ) do | is_published, name |
  @rubric = @user.rubrics.new(
    name:,
    description: Faker::GreekPhilosophers.quote,
    school: @user.school,
    published: 'published' == is_published
  )
  @rubric.criteria.new(
    description: Faker::Company.industry,
    sequence: 1,
    l1_description: Faker::Company.bs
  )
  @rubric.save
  log @rubric.errors.full_messages if @rubric.errors.present?
end

Then( 'retrieve the {string} rubric' ) do | whichRubric |
  @rubric = if 'latest' == whichRubric
              Rubric.last
            else
              Rubric.find_by name: whichRubric
            end
end

Then( 'the rubric {string} is {string}' ) do | field, value |
  case field.downcase
  when 'name'
    @rubric.name.should eq value
  when 'description'
    @rubric.description.should eq value
  else
    true.should be false
  end
end

Then( 'the user sees {int} rubrics' ) do | count |
  wait_for_render
  rubrics = find_all( :xpath, '//tbody/tr' )
  if count.zero? && 1 == rubrics.size
    has_content?( 'No rubrics found' ).should be true
  else
    rubrics.size.should eq count
  end
end

Then( 'the user sets criteria {int} {string} to {string}' ) do | criteria_num, field_name, value |
  row = find_all( :xpath, '//tbody/tr' )[criteria_num - 1]
  field_num = case field_name.downcase
              when 'description'
                1
              when 'weight'
                2
              when 'l1_description'
                3
              when 'l2_description'
                4
              when 'l3_description'
                5
              when 'l4_description'
                6
              when 'l5_description'
                7
              else
                true.should be false
              end
  field = row.find_all( 'td' )[field_num]
  field.click

  field = find( :id, field_name.downcase )

  field.send_keys [:control, 'a'], :backspace
  field.send_keys [:command, 'a'], :backspace

  field.send_keys value
  field.send_keys :enter
end

Then( 'the user sets criteria {int} level {int} to {string}' ) do | criteria_num, level, value |
  row = find_all( :xpath, '//tbody/tr' )[criteria_num - 1]
  field_num = level + 2

  field = row.find_all( 'td' )[field_num]
  field.click

  field = find_by_id( "l#{level}_description" )
  field.send_keys [:control, 'a'], :backspace
  field.send_keys [:command, 'a'], :backspace

  field.send_keys value
  field.send_keys :enter
end

Then( 'the user sees the criteria {int} weight is {int}' ) do | criteria_num, weight |
  row = find_all( :xpath, '//tbody/tr' )[criteria_num - 1]
  field = row.find_all( 'td' )[2]

  field.text.to_i.should eq weight
end

Then( 'the user adds a new criteria' ) do
  click_button 'New Criteria'
end

Then( 'the user will see an empty criteria {int}' ) do | criteria_num |
  wait_for_render
  row = find_all( :xpath, '//tbody/tr' )[criteria_num - 1]
  field = row.find_all( 'td' )[1]
  field.text.should eq 'New Criteria'
end

Then( 'the user sets criteria {int} {string} to to {string}' ) do | criteria_num, field_name, value |
  fields = find( :xpath,
                 "//div[contains(@class,'MuiDataGrid-row')][#{criteria_num - 1}]/div[@data-field='#{field_name}']/div" )
  fields.size.should eq 1

  field.double_click
  text.size.times do
    send_keys :backspace
  end
  send_keys value
  send_keys :enter
end

Then( 'the user sets the criteria {int} weight to {int}' ) do | criteria_num, weight |
  row = find_all( :xpath, '//tbody/tr' )[criteria_num - 1]
  field = row.find_all( 'td' )[2]

  field.click

  field = find_by_id( 'weight' )
  field.send_keys [:control, 'a'], :backspace
  field.send_keys [:command, 'a'], :backspace

  field.send_keys weight
  field.send_keys :enter
end

Then( 'retrieve the {string} rubric from the db' ) do | name |
  @rubric = if 'latest' == name
              Rubric.last
            else
              @rubric = Rubric.find_by name:
            end
end

Then( 'the user is the owner of the rubric' ) do
  @rubric.user.should eq @user
end

Then( 'the rubric version is {int}' ) do | version |
  @rubric.version.should eq version
end

Then( 'the rubric {string} field is {string}' ) do | field_name, value |
  case field_name.downcase
  when 'description'
    @rubric.description.should eq value
  when 'name'
    @rubric.name.should eq value
  else
    true.should be false
  end
end

Then( 'the rubric criteria {int} {string} is {string}' ) do | criteria_num, field_name, value |
  criteria = @rubric.criteria[criteria_num - 1]
  case field_name.downcase
  when 'description'
    criteria.description.should eq value
  else
    true.should be false
  end
end

Then( 'the rubric criteria {int} level {int} is {string}' ) do | criteria_num, level, value |
  criteria = @rubric.criteria[criteria_num - 1]
  case level
  when 1
    criteria.l1_description.should eq value
  when 2
    criteria.l2_description.should eq value
  when 3
    criteria.l3_description.should eq value
  when 4
    criteria.l4_description.should eq value
  when 5
    criteria.l5_description.should eq value
  else
    true.should be false
  end
end

Then( 'the rubric criteria {int} weight is {int}' ) do | criteria_num, weight |
  criteria = @rubric.criteria[criteria_num - 1]
  criteria.weight.should eq weight
end

Then( 'the user searches for {string}' ) do | search_string |
  field = find( :xpath, "//input[@id='rubric-search']" )
  ack_messages
  oldVal = field.value
  field.click

  oldVal.size.times do
    send_keys :backspace
  end
  send_keys search_string
  sleep 0.06
end

Then( 'the user edits the {string} rubric' ) do | name |
  xpath = "//tbody/tr/td[contains(.,'#{name}')]"
  field = find( :xpath, xpath )
  field.click
end

Then( 'the rubric {string} published' ) do | is_published |
  @rubric.published.should eq( 'is' == is_published )
end

Then( 'the rubric {string} active' ) do | is_active |
  @rubric.active.should eq( 'is' == is_active )
end

Given( 'the {string} rubric is published' ) do | name |
  rubric = Rubric.find_by( name: )
  rubric.published = true
  rubric.save
end

Then( 'the user copies the {string} rubric' ) do | rubric_name |
  row = find( :xpath, "//tr/td[text()=\"#{rubric_name}\"]/following-sibling::td/button[@id='copy_rubric']" )
  row.click
end

Then( 'the user copies criteria {int}' ) do | criteria_num |
  find_all( :xpath, "//button[@id='copy_criteria']" )[criteria_num - 1].click
end

Then( 'the rubric {string} is {int}' ) do | field_name, value |
  case field_name.downcase
  when 'version'
    @rubric.version.should eq value
  else
    true.should be false
  end
end

Then( 'the rubric owner {string} the user' ) do | is_owner |
  if 'is' == is_owner
    @rubric.user.should eq @user
  else
    @rubric.user.should_not eq @user
  end
end

Then( 'the rubric parent is {string} version {int}' ) do | name, version |
  @rubric.parent.name.should eq name
  @rubric.parent.version.should eq version
end

Then( 'the rubric parent is empty' ) do
  @rubric.parent.should be nil
end

Then( 'the {string} rubric has {int} criteria' ) do | rubric_name, criteria_count |
  rubric = Rubric.find_by name: rubric_name

  start_at = rubric.criteria.size + 1
  start_at.upto( criteria_count ) do | index |
    criteria = rubric.criteria.new(
      description: Faker::Company.buzzword,
      weight: rand( 100 ),
      sequence: index + 1,
      l1_description: Faker::Lorem.sentence
    )
    next unless rand( 2 ) > 1

    criteria.l2_description = Faker::Lorem.sentence
    next unless rand 2 > 1

    criteria.l3_description = Faker::Lorem.sentence
    if rand 2 > 1
      criteria.l4_description = Faker::Lorem.sentence
      criteria.l5_description = Faker::Lorem.sentence if rand 2 > 1
    end
  end
  rubric.criteria.sort_by( &:sequence ).each_with_index do | criterium, index |
    criterium.sequence = ( index + 1 ) * 2
  end
  rubric.save
  puts rubric.errors.full_messages unless rubric.errors.empty?
end

Then( 'the user adds a level to criteria {int}' ) do | criteria_num |
  levels = find_all( :xpath, "//tbody/tr[#{criteria_num - 1}]/td" )

  levels.each_with_index do | level, index |
    next if level.text.present?

    level.double_click
    send_keys "level #{index}"
    send_keys :enter
    break
  end
end

Then( 'remember the data for criteria {int}' ) do | criteria_num |
  @criterium = @rubric.criteria.order( :sequence )[criteria_num - 1]
end

Then( '{string} sequence of remembered criteria by {int}' ) do | inc_or_dec, raw_delta |
  delta = 'increment' == inc_or_dec ? raw_delta * 2 : raw_delta * -2
  @criterium.sequence += delta
end

Then( 'the user sees that criteria {int} matches the remembered criteria' ) do | criteria_num |
  fields = find_all( :xpath, "//div[contains(@class,'MuiDataGrid-row')][#{criteria_num}]/div" )
  fields.each do | field |
    case field['data-field']
    when 'description'
      @criterium.description.should eq field.text
    when 'weight'
      @criterium.weight.should eq field.text.to_i
    when 'l1_description'
      @criterium.l1_description.should eq field.text
    when 'l2_description'
      if field.text.blank?
        @criterium.l2_description.should be nil
      else
        @criterium.l2_description.should eq field.text
      end
    when 'l3_description'
      if field.text.blank?
        @criterium.l3_description.should be nil
      else
        @criterium.l3_description.should eq field.text
      end
    when 'l4_description'
      if field.text.blank?
        @criterium.l4_description.should be nil
      else
        @criterium.l4_description.should eq field.text
      end
    when 'l5_description'
      if field.text.blank?
        @criterium.l5_description.should be nil
      else
        @criterium.l5_description.should eq field.text
      end
    when 'sequence'
      @criterium.sequence.should eq field.text.to_i
    when 'actions'
      # no test - these are buttons
    else
      # untested field
      true.should eq( false ), "field not tested: #{field['data-field']}: #{field.text}" if field.text.present?
    end
  end
end

Then( 'the user deletes criteria {int}' ) do | criteria_num |
  find_all( :xpath, "//button[@id='delete_criteria']" )[criteria_num - 1].click
end

Then( 'criteria {int} matches the remembered criteria' ) do | criteria_num |
  test_criteria = @rubric.criteria[criteria_num - 1]
  test_criteria.description.should eq @criterium.description
  test_criteria.weight.should eq @criterium.weight
  test_criteria.l1_description.should eq @criterium.l1_description
  test_criteria.l2_description.should eq @criterium.l2_description
  test_criteria.l3_description.should eq @criterium.l3_description
  test_criteria.l4_description.should eq @criterium.l4_description
  test_criteria.l5_description.should eq @criterium.l5_description
end

Then( 'the user moves criteria {int} {string}' ) do | criteria_num, up_or_down |
  wait_for_render
  find_all( :xpath, "//button[@id='#{up_or_down}_criteria']" )[criteria_num - 1].click
end

Then( 'the user deletes the {string} rubric' ) do | rubric_name |
  row = find( :xpath, "//tr/td[contains(.,\"#{rubric_name}\")]/following-sibling::td/button[@id='delete_rubric']" )
  row.click
end

Then( 'the user can not {string} the {string} rubric' ) do | action, rubric_name |
  case action
  when 'delete'
    button = find( :xpath, "//tr/td[contains(.,\"#{rubric_name}\")]/following-sibling::td/button[@id='delete_rubric']" )
    button.disabled?.should be true
  else
    true.should be false
  end
end

Given( 'there exists a rubric published by another user' ) do
  users = User.includes( :school ).where.not( id: @user.id )
  another_user = users.where.not( school_id: nil ).sample
  @rubric = another_user.school.rubrics.new(
    name: Faker::JapaneseMedia::StudioGhibli.character.to_s,
    description: Faker::JapaneseMedia::StudioGhibli.quote,
    user: another_user
  )
  rand( 1..10 ).times do | index |
    levels = rand( 5 )
    criteria = @rubric.criteria.new(
      description: Faker::Company.industry,
      sequence: index,
      l1_description: Faker::Company.bs,
      l2_description: levels >= 0 ? Faker::Company.bs : nil,
      l3_description: levels >= 1 ? Faker::Company.bs : nil,
      l4_description: levels >= 2 ? Faker::Company.bs : nil,
      l5_description: levels >= 3 ? Faker::Company.bs : nil
    )
    log criteria.errors.full_messages unless criteria.save
  end
  @rubric.save
  log @rubric.errors.full_messages if @rubric.errors.present?
end

Then( 'retrieve the latest child of the rubric' ) do
  @rubric.reload
  @rubric = @rubric.child_versions.last
end

Then( 'the rubric has a parent' ) do
  @rubric.parent.blank?.should_not be true
end

Given( 'the existing rubric is attached to this assignment' ) do
  @assignment.rubric = @rubric
  @assignment.save
  log @assignment.errors.full_messages if @assignment.errors.present?
end

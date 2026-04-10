# frozen_string_literal: true

require 'faker'

Given( /^the project measures (\d+) factors$/ ) do | num_factors |
  Faker::Job.unique.clear
  bp = FactorPack.new(
    name: "#{Faker::Company.industry}-#{Faker::Color.color_name} Factor Pack",
    description: Faker::Company.bs
  )
  num_factors.to_i.times do
    factor = bp.factors.new(
      name: "#{Faker::Job.unique.key_skill} Factor",
      description: Faker::Company.catch_phrase
    )
    factor.save
    log factor.errors.full_messages if factor.errors.present?
  end
  bp.save
  log bp.errors.full_messages if bp.errors.present?
  @project.factor_pack = bp
  @project.save
  log @project.errors.full_messages if @project.errors.present?
end

Given( /^the project started last month and lasts (\d+) weeks, opened yesterday and closes tomorrow$/ ) do | num_weeks |
  @project.start_date = ( Time.zone.today - 1.month )
  @project.end_date = ( @assessment.start_date + num_weeks.to_i.weeks )
  @project.start_dow = Date.yesterday.wday
  @project.end_dow = Date.tomorrow.wday
end

When( /^the user submits the installment$/ ) do
  click_link_or_button( 'Submit Weekly Check-In' )
  wait_for_render
end

Then( /^there should be no error$/ ) do
  page.should_not have_content( 'Unable to reconcile check-in values.' )
  page.should_not have_content( 'assessment has expired' )
end

Then( /^the user should see an error indicating that the installment request expired$/ ) do
  page.should have_content( 'assessment has expired' )
end

When( /^user clicks the link to the project$/ ) do
  step 'the user enables the "Group Name" table view option'
  find( :xpath, "//tbody/tr/td[text()='#{@project.group_for_user( @user ).name}']" ).click

  wait_for_render
end

Then( /^the user should enter values summing to (\d+), "(.*?)" across each column$/ ) do | column_points, distribution |
  task = @user.waiting_student_tasks[0]

  @value_ratio = distribution
  @installment_values = {}
  if column_points.to_i <= 0
    page.all( :xpath, '//input[starts-with(@id,"installment_values_attributes_")]' ).each do | element |
      element.set 0 if element[:id].end_with? 'value'
    end
  elsif 'evenly' == distribution
    cell_value = column_points.to_i / task.group_for_user( @user ).users.count
    page.all( :xpath, '//input[starts-with(@name,"slider_")]' ).each do | element |
      element.set cell_value if element[:id].end_with? 'value'
    end
  else
    # push the panel into debug mode
    @project.factors.each do | factor |
      # Open the factor panel
      find( :xpath, "//span[@factorId='#{factor[:id]}']" ).click

      elements = page
                 .all( :xpath, "//input[@data-factor-id=#{factor.id}]",
                       visible: false )

      factor_vals = Hash[elements.collect { | element | [element['data-contributor-id'], element.value] }]

      actions = []
      rand( 3..10 ).times do
        actions << {
          increment: rand( 2000 ) * ( 1 == rand( 2 ) ? -1 : 1 ),
          target: factor_vals.keys.sample
        }
      end

      actions.each_with_index do | action, _index |
        target = action[:target]
        increment = action[:increment]
        contrib = find( :xpath, "//input[@data-factor-id='#{factor.id}'][@data-contributor-id='#{target}']" )

        # let's do the allocation math - this doesn't have to be performant
        new_val = ( increment + contrib.value.to_i ).clamp( 0, Installment::TOTAL_VAL )
        contrib.set new_val

        wait_for_render

        sum = all( :xpath, "//input[@data-factor-id='#{factor.id}']" ).reduce( 0 ) do | total, slider |
          factor_vals[slider['data-contributor-id']] = slider.value
          total + slider.value.to_i
        end
        sum.should eq Installment::TOTAL_VAL
      end

      # elements[index].set (column_points.to_i - total)
      # factor_vals << column_points.to_i - total
      @installment_values[factor.id] = factor_vals
    end
  end
end

Then( /^the installment form should request factor x user values$/ ) do
  tasks = @user.waiting_student_tasks
  group = tasks[0].group_for_user( @user )
  factors = tasks[0].factors

  expected_count = group.users.count * factors.count
  actual_count = 0
  page.all( :xpath, "//div[@id='installments']//a[@role='button']" ).each do | tab |
    tab.click unless 1 == tab.all( :xpath, 'ancestor::div[contains(@class,"p-accordion-tab-active")]' ).size
    wait_for_render
    tab_count = tab.all( :xpath,
                         'ancestor::div[contains(@class,"p-accordion-tab-active")]//div[@data-pc-name="slider"]' ).size
    actual_count += tab_count
  end

  actual_count.should eq expected_count
end

Then( /^the assessment should show up as completed$/ ) do
  # Using some cool xpath stuff to check for proper content
  group_name = @project.group_for_user( @user ).name
  step 'the user switches to the "Task View" tab'

  step 'the user enables the "Group Name" table view option'
  page.should have_xpath( "//tbody/tr/td[contains(.,'#{group_name}')]" ),
              "No link to assessment for #{group_name} found"
  page.should have_xpath( "//tbody/tr/td[contains(.,'Completed')]" ),
              "No 'completed' message"
end

Then( /^the user logs in and submits an installment$/ ) do
  step 'the user "has" had demographics requested'
  step 'the user logs in'
  step 'the user should see a successful login message'
  step 'the user switches to the "Task View" tab'
  step 'user clicks the link to the project'
  step 'user will be presented with the installment form'
  step 'the installment form should request factor x user values'
  step 'the user should enter values summing to 6000, "evenly" across each column'
  step 'the user submits the installment'
  step 'there should be no error'
end

Then( /^the user logs out$/ ) do
  wait_for_render
  find( :id, 'main-menu-button' ).click
  find( :id, 'logout-menu-item' ).click
  wait_for_render
  page.quit
end

Then( /^there should be an error$/ ) do
  page.should have_content( 'The factors in each category must equal 6000.' )
end

Then( /^the installment values will match the submit ratio$/ ) do
  installment = Installment.last
  if 'evenly' == @value_ratio
    baseline = installment.values[0].value
    installment.values.each do | value |
      value.value.should eq baseline
    end
  else
    recorded_vals = {}
    installment.values.each do | value |
      factor_vals = recorded_vals[value.factor.id]
      factor_vals = [] if factor_vals.nil?
      factor_vals << [value.user_id, value.value]
      recorded_vals[value.factor.id] = factor_vals
    end

    recorded_vals.keys.each do | factor_id |
      set_vals = @installment_values[factor_id]
      set_tot = set_vals.values.reduce( 0 ) { | sum, x | sum + x.to_i }
      set_vals_a = []

      set_vals.keys.sort.each do | key |
        set_vals_a << set_vals[key].to_f / set_tot
      end

      rec_vals = recorded_vals[factor_id].sort { | a, b | a[0] - b[0] }.collect { | item | item[1] }
      rec_tot = rec_vals.inject { | sum, x | sum + x }
      rec_vals.collect! { | x | x.to_f / rec_tot }

      set_vals_a.should eq rec_vals
    end

  end
end

Then( /^the user enters a comment "([^"]*)" personally identifiable information$/ ) do | anonymized |
  @comment = 'A nice, bland, comment'
  @anon_comment = @comment

  if 'with' == anonymized
    group =  @project.group_for_user( @user )
    user_one = group.users.last
    user_two = group.users.first
    user_three = group.users.sample
    @comment = "#{group.get_name( false )} was awesome! "
    @comment += "#{user_one.first_name} and "
    @comment += "#{user_two.first_name} flew through the their "
    @comment += "work. #{@project.get_name( false )} is fun and I think "
    @comment += "#{user_three.last_name} likes the "
    @comment += "#{@project.course.get_name( false )} course here at "
    @comment += "#{@project.course.school.get_name( false )}. Not bad. "
    @comment += "I don't regret taking "
    @comment += "#{@project.course.get_number( false )}. "
    @comment += "#{user_three.first_name}'s nice."

    @anon_comment = "#{group.get_name( true )} was awesome! "
    @anon_comment += "#{user_one.anon_first_name} and "
    @anon_comment += "#{user_two.anon_first_name} flew through the their "
    @anon_comment += "work. #{@project.get_name( true )} is fun and I think "
    @anon_comment += "#{user_three.anon_last_name} likes the "
    @anon_comment += "#{@project.course.get_name( true )} course here at "
    @anon_comment += "#{@project.course.school.get_name( true )}. Not bad. "
    @anon_comment += "I don't regret taking "
    @anon_comment += "#{@project.course.get_number( true )}. "
    @anon_comment += "#{user_three.anon_first_name}'s nice."

  end

  find( :xpath, '//*[text()="Would you like to add additional comments?"]' ).click
  page.fill_in( 'comments', with: @comment, visible: :all, disabled: :all )
end

Then( /^the comment matches what was entered$/ ) do
  Installment.last.comments.should eq @comment
end

Then( /^the anonymous comment "([^"]*)"$/ ) do | comment_status |
  installment = Installment.last
  case comment_status.downcase
  when 'is empty'
    installment.anon_comments.blank?.should eq true

  when 'matches'
    installment.pretty_comment( false ).should eq @comment
    installment.pretty_comment( true ).should eq @anon_comment

  when 'is anonymized'
    installment.pretty_comment( true ).should_not eq @comment
    installment.pretty_comment( false ).should eq @comment
    installment.pretty_comment( true ).should eq @anon_comment

  else
    pending
  end
end

Then 'the installment will successfully save' do
  # Using aria-labl instead of title because of some strange JavaScript
  # error.
  waits = 0
  unless !all( :xpath, "//div[contains(.,'success')]" ).empty? || waits > 3

    sleep( 0.3 )
    waits += 1
    waits.should be < 3
  end
end

Then( /^user will be presented with the installment form$/ ) do
  wait_for_render
  page.should have_content 'Your weekly check-in'
  page.should have_content @project.name
end

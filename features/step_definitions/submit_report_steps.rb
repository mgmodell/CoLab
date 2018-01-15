# frozen_string_literal: true

require 'forgery'

Given /^the project measures (\d+) factors$/ do |num_factors|
  bp = FactorPack.make
  num_factors.to_i.times do
    bp.factors << Factor.make
  end
  bp.save
  puts bp.errors.full_messages unless bp.errors.blank?
  @project.factor_pack = bp
  @project.save
  puts @project.errors.full_messages unless @project.errors.blank?
end

Given /^the project started last month and lasts (\d+) weeks, opened yesterday and closes tomorrow$/ do |num_weeks|
  @project.start_date = (Date.today - 1.month)
  @project.end_date = (@assessment.start_date + num_weeks.to_i.weeks)
  @project.start_dow = Date.yesterday.wday
  @project.end_dow = Date.tomorrow.wday
end

When /^the user submits the installment$/ do
  click_link_or_button('Submit Weekly Installment')
end

When /^the user returns home$/ do
  visit '/'
end

Then /^there should be no error$/ do
  page.should_not have_content('Unable to reconcile installment values.')
  page.should_not have_content('assessment has expired')
end

Then /^the user should see an error indicating that the installment request expired$/ do
  page.should have_content('assessment has expired')
end

When /^user clicks the link to the project$/ do
  first(:link, @project.group_for_user(@user).name).click
  # click_link_or_button @project.group_for_user(@user).name, visible: :all
end

Then /^the user should enter values summing to (\d+), "(.*?)" across each column$/ do |column_points, distribution|
  task = @user.waiting_student_tasks[0]

  @value_ratio = distribution
  @installment_values = {}
  if column_points.to_i <= 0
    page.all(:xpath, '//input[starts-with(@id,"installment_values_attributes_")]').each do |element|
      element.set 0 if element[:id].end_with? 'value'
    end
  elsif distribution == 'evenly'
    cell_value = column_points.to_i / task.group_for_user(@user).users.count
    page.all(:xpath, '//input[starts-with(@id,"installment_values_attributes_")]').each do |element|
      element.set cell_value if element[:id].end_with? 'value'
    end
  else
    @project.factors.each do |factor|
      factor_vals = []
      elements = page.all(:xpath, "//input[contains(@class,\"#{factor.name.delete(' ')}\")]")
      index = 0
      total = 0
      while index < (elements.length - 1)
        what_is_left = column_points.to_i - total
        value = Random.rand(what_is_left)
        elements[index].set value
        total += value
        factor_vals << value
        index += 1
      end
      elements[index].set (column_points.to_i - total)
      factor_vals << column_points.to_i - total
      @installment_values[factor.id] = factor_vals
    end
  end
end

Then /^the installment form should request factor x user values$/ do
  tasks = @user.waiting_student_tasks
  group = tasks[0].group_for_user(@user)
  factors = tasks[0].factors

  expected_count = group.users.count * factors.count

  actual_count = 0
  page.all(:xpath, '//input[starts-with(@id,"installment_values_attributes_")]').each do |element|
    actual_count += 1 if element[:id].end_with? 'value'
  end
  actual_count.should eq expected_count
end

Then /^the assessment should show up as completed$/ do
  # Using some cool xpath stuff to check for proper content
  link_text = @project.group_for_user(@user).name

  page.should have_xpath("//a[contains(., '#{link_text}')]/.."), 'No link to assessment'
  page.should have_xpath("//td[contains(., 'Completed')]"), "No 'completed' message"
end

Then /^the user logs in and submits an installment$/ do
  step 'the user "has" had demographics requested'
  step 'the user logs in'
  step 'the user should see a successful login message'
  step 'user clicks the link to the project'
  step 'user will be presented with the installment form'
  step 'the installment form should request factor x user values'
  step 'the user should enter values summing to 6000, "evenly" across each column'
  step 'the user submits the installment'
  step 'there should be no error'
end

Then /^the user logs out$/ do
  click_link_or_button('Logout')
end

Then /^there should be an error$/ do
  page.should have_content('The factors in each category must equal 6000.')
end

Then /^the installment values will match the submit ratio$/ do
  installment = Installment.last
  if @value_ratio == 'evenly'
    baseline = installment.values[0].value
    installment.values.each do |value|
      value.value.should eq baseline
    end
  else
    recorded_vals = {}
    installment.values.each do |value|
      factor_vals = recorded_vals[value.factor.id]
      factor_vals = [] if factor_vals.nil?
      factor_vals << value.value
      recorded_vals[value.factor.id] = factor_vals
    end

    recorded_vals.keys.each do |factor_id|
      set_vals = @installment_values[factor_id]
      set_tot = set_vals.inject { |sum, x| sum + x }
      set_vals.collect! { |x| x.to_f / set_tot }

      rec_vals = recorded_vals[factor_id]
      rec_tot = rec_vals.inject { |sum, x| sum + x }
      rec_vals.collect! { |x| x.to_f / rec_tot }

      set_vals.should eq rec_vals
    end

  end
end

Then /^the user enters a comment "([^"]*)" personally identifiable information$/ do |anonymized|
  @comment = 'A nice, bland, comment'
  @anon_comment = @comment

  if anonymized == 'with'
    group =  @project.group_for_user(@user)
    user_one = group.users.last
    user_two = group.users.first
    user_three = group.users.sample
    @comment = "#{group.get_name(false)} was awesome! "
    @comment += "#{user_one.first_name} and "
    @comment += "#{user_two.first_name} flew through the their "
    @comment += "work. #{@project.get_name(false)} is fun and I think "
    @comment += "#{user_three.last_name} likes the "
    @comment += "#{@project.course.get_name(false)} course here at "
    @comment += "#{@project.course.school.get_name(false)}. Not bad. "
    @comment += "I don't regret taking "
    @comment += "#{@project.course.get_number(false)}. "
    @comment += "#{user_three.first_name}'s nice."

    @anon_comment = "#{group.get_name(true)} was awesome! "
    @anon_comment += "#{user_one.anon_first_name} and "
    @anon_comment += "#{user_two.anon_first_name} flew through the their "
    @anon_comment += "work. #{@project.get_name(true)} is fun and I think "
    @anon_comment += "#{user_three.anon_last_name} likes the "
    @anon_comment += "#{@project.course.get_name(true)} course here at "
    @anon_comment += "#{@project.course.school.get_name(true)}. Not bad. "
    @anon_comment += "I don't regret taking "
    @anon_comment += "#{@project.course.get_number(true)}. "
    @anon_comment += "#{user_three.anon_first_name}'s nice."

  end

  page.fill_in('Comments', with: @comment, visible: :all, disabled: :all)
end

Then /^the comment matches what was entered$/ do
  Installment.last.comments.should eq @comment
end

Then /^the anonymous comment "([^"]*)"$/ do |comment_status|
  installment = Installment.last
  case comment_status
  when 'is empty'
    installment.anon_comments.blank?.should eq true

  when 'matches'
    installment.pretty_comment(false).should eq @comment
    installment.pretty_comment(true).should eq @anon_comment

  when 'is anonymized'
    installment.pretty_comment(true).should_not eq @comment
    installment.pretty_comment(false).should eq @comment
    installment.pretty_comment(true).should eq @anon_comment

  else
    pending
  end
end

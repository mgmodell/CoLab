# frozen_string_literal: true

Given(/^the Bingo! is group-enabled with the project and a (\d+) percent group discount$/) do |group_discount|
  @bingo.group_option = true
  @project.should_not be_nil
  @bingo.project = @project
  @bingo.group_discount = group_discount
end

Then(/^the user "([^"]*)" see collaboration was requested$/) do |collaboration_pending|
  wait_for_render
  link_text = "Your teammates in #{@group.get_name(false)} want to collaborate"
  case collaboration_pending.downcase
  when 'should'
    page.should have_content link_text
  when 'should not'
    page.should_not have_content link_text
  else
    log "We didn't test anything there: " + collaboration_pending
  end
end

When(/^the user requests collaboration$/) do
  wait_for_render
  link_text = "Invite your teammates in #{@group.get_name(false)} to help?"
  expect(page).to have_content link_text
  link = find(:xpath, "//a[contains(.,'#{link_text}')]")
  link.click
end

When(/^group user (\d+) logs in$/) do |user_count|
  @user = @group.users[user_count.to_i - 1]
  step 'the user "has" had demographics requested'
  step 'the user logs in'
end

Then(/^the user "([^"]*)" see they're waiting on a collaboration response$/) do |collaboration_pending|
  case collaboration_pending.downcase
  when 'should'
    page.should have_content 'awaiting a response to your group help request'
  when 'should not'
    page.should_not have_content 'awaiting a response to your group help request'
  else
    log "We didn't test anything there: " + collaboration_pending
  end
end

Then(/^the user "([^"]*)" the collaboration request$/) do |accept_or_decline|
  wait_for_render
  case accept_or_decline.downcase
  when 'accepts'
    btn = find(:xpath, "//a[text()='Accept']")
    # click_link_or_button 'Accept'
  when 'declines'
    btn = find(:xpath, "//a[text()='Decline']")
    # click_link_or_button 'Decline'
  else
    log "We didn't test anything there: " + accept_or_decline
  end
  btn.click
end

Then(/^the user "([^"]*)" see collaboration request button$/) do |button_present|
  case button_present.downcase
  when 'should'
    page.should have_content 'Invite your group to help?'
  when 'should not'
    page.should_not have_content 'Invite your group to help?'
  else
    log "We didn't test anything there: " + button_present
  end
end

When(/^the user populates (\d+) additional "([^"]*)" entries$/) do |count, field|
  # required_term_count = @bingo.required_terms_for_group(@bingo.project.group_for_user(@user))

  @entries_lists = {} if @entries_lists.nil?
  @entries_lists[@user] = [] if @entries_lists[@user].nil?
  @entries_list = @entries_lists[@user]

  existing_count = @entries_list.count
  count.to_i.times do |index|
    if @entries_list[existing_count + index].blank?
      @entries_list[existing_count + index] = { 'term' => '', 'definition' => '' }
    end
    @entries_list[existing_count + index][field] = if field == 'term'
                                                     Faker::Company.industry
                                                   else
                                                     Faker::Company.bs
                                                   end
    page.fill_in("#{field}_#{existing_count + index}",
                 with: @entries_list[existing_count + index][field])
  end
end

When(/^the user changes the first (\d+) "([^"]*)" entries$/) do |count, field|
  @entries_lists = {} if @entries_lists.nil?
  @entries_lists[@user] = [] if @entries_lists[@user].nil?
  @entries_list = @entries_lists[@user]

  entries_array = [ ]
  @entries_lists.keys.each do |user_id|
    @entries_lists[ user_id ].each do |entry|
      entries_array.push entry
    end
  end
  field_count = page.all(:xpath, "//textarea[contains(@id, 'definition_')]").count


  count.to_i.times do |index|
    # Index to the field to change
    rand_ind = Random.rand( field_count )

    # Pull the existing values
    existing_term = page.find(:xpath, "//input[@id='term_#{rand_ind}']").value
    existing_def = page.find(:xpath, "//textarea[@id='definition_#{rand_ind}']").value

    # Gen the new term
    new_val = if field == 'term'
                Faker::Company.industry
              else
                Faker::Company.bs
              end

    if existing_term.blank? && existing_def.blank?
      @entries_list.push( { field => new_val } )
    else
      found = false
      entries_array.each do |entry|
        if 'term' == field && entry['definition'] == existing_def
          entry['term'] = new_val
          page.fill_in("#{field}_#{rand_ind}",
                       with: new_val )
          found = true
        elsif 'definition' == field && entry['term'] == existing_term
          entry['definition'] = new_val
          page.fill_in("#{field}_#{rand_ind}",
                       with: new_val )
          found = true
        end

        break if found

      end
    end
  end
end

Then(/^the candidate lists have been merged$/) do
  @entries_lists = {} if @entries_lists.nil?
  combined_list = []
  @bingo.project.group_for_user(@user).users.each do |user|
    next if @entries_lists[user].blank?

    @entries_lists[user].each do |list_item|
      combined_list << list_item if list_item['term'].present? || list_item['definition'].present?
    end
  end
  @bingo.project.group_for_user(@user).users.each do |user|
    @entries_lists[user] = combined_list
  end
end

Then(/^all course users should see the terms list$/) do
  temp_user = @user
  @course.users.each do |user|
    @user = user
    step 'the user "has" had demographics requested'
    step 'the user logs in'
    step 'user should see 1 open task'
    step 'the user clicks the link to the candidate list'
    step 'the user should see the Bingo candidate list'
    step 'the user will see 10 term field sets'
    step 'the user logs out'
  end
  @user = temp_user
end

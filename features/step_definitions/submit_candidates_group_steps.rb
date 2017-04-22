# frozen_string_literal: true
Given /^the Bingo! is group\-enabled with the project and a (\d+) percent group discount$/ do |group_discount|
  @bingo.group_option = true
  @project.should_not be_nil
  @bingo.project = @project
  @bingo.group_discount = group_discount
end

Then /^the user "([^"]*)" see collaboration was requested$/ do |collaboration_pending|
  case collaboration_pending.downcase
  when 'should'
    page.should have_content 'Your team wants to collaborate'
  when 'should not'
    page.should_not have_content 'Your group has asked you to collaborate: '
  else
    puts "We didn't test anything there: " + collaboration_pending
  end
end

When /^the user requests collaboration$/ do
  page.should have_content 'Invite your group to help?'
  click_link_or_button 'Invite your group to help?'
end

When /^group user (\d+) logs in$/ do |user_count|
  @user = @group.users[user_count.to_i - 1]
  step 'the user "has" had demographics requested'
  step 'the user logs in'
end

Then /^the user "([^"]*)" see they're waiting on a collaboration response$/ do |collaboration_pending|
  case collaboration_pending.downcase
  when 'should'
    page.should have_content 'awaiting a response to your group help request'
  when 'should not'
    page.should_not have_content 'awaiting a response to your group help request'
  else
    puts "We didn't test anything there: " + collaboration_pending
  end
end

Then /^the user "([^"]*)" the collaboration request$/ do |accept_or_decline|
  case accept_or_decline.downcase
  when 'accepts'
    click_link_or_button 'Accept'
  when 'declines'
    click_link_or_button 'Decline'
  else
    puts "We didn't test anything there: " + accept_or_decline
  end
end

Then /^the user "([^"]*)" see collaboration request button$/ do |button_present|
  case button_present.downcase
  when 'should'
    page.should have_content 'Invite your group to help?'
  when 'should not'
    page.should_not have_content 'Invite your group to help?'
  else
    puts "We didn't test anything there: " + button_present
  end
end

When /^the user populates (\d+) additional "([^"]*)" entries$/ do |count, field|
  #required_term_count = @bingo.required_terms_for_group(@bingo.project.group_for_user(@user))

  @entries_lists = {} if @entries_lists.nil?
  @entries_lists[@user] = [] if @entries_lists[@user].nil?
  @entries_list = @entries_lists[@user]

  existing_count = @entries_list.count
  count.to_i.times do |index|
    @entries_list[existing_count + index] = { 'term' => '', 'definition' => '' } if @entries_list[existing_count + index].blank?
    @entries_list[existing_count + index][field] = field == 'term' ?
                        Forgery::Name.industry :
                        Forgery::Basic.text
    page.fill_in("candidate_list_candidates_attributes_#{existing_count + index}_#{field}",
                 with: @entries_list[existing_count + index][field])
  end
end

When /^the user changes the first (\d+) "([^"]*)" entries$/ do |count, field|
  @entries_lists = {} if @entries_lists.nil?
  @entries_lists[@user] = [] if @entries_lists[@user].nil?
  @entries_list = @entries_lists[@user]

  count.to_i.times do |index|
    @entries_list[index] = {} if @entries_list[index].blank?
    @entries_list[index][field] = field == 'term' ?
                        Forgery::Name.industry :
                        Forgery::Basic.text
    page.fill_in("candidate_list_candidates_attributes_#{index}_#{field}",
                 with: @entries_list[index][field])
  end
end

Then /^the candidate lists have been merged$/ do
  @entries_lists = {} if @entries_lists.nil?
  combined_list = []
  @bingo.project.group_for_user(@user).users.each do |user|
    next if @entries_lists[user].blank?
    @entries_lists[user].each do |list_item|
      if list_item['term'].present? || list_item['definition'].present?
        combined_list << list_item
      end
    end
  end
  @bingo.project.group_for_user(@user).users.each do |user|
    @entries_lists[user] = combined_list
  end
end

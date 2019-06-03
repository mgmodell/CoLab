# frozen_string_literal: true

Then /^we debug$/ do
  byebug
end

Then /^show me the page$/ do
  puts page.body
end

Then /^show the entries list$/ do
  @entries_lists = {} if @entries_lists.blank?
  @entries_lists[@user] = [] if @entries_lists[@user].blank?
  @entries_list = @entries_lists[@user]
  @entries_list.each do |item|
    term = item['term'].presence || ''
    definition = item['definition'].presence || ''
    puts term + ' | ' + definition
  end
end

# frozen_string_literal: true
Then /^we debug$/ do
  byebug
end

Then /^show me the page$/ do
  puts page.body
end

# frozen_string_literal: true

Then(/^we debug$/) do
  byebug
end

Then(/^show me the page$/) do
  puts page.body
end

Then(/^show the entries list$/) do
  @entries_lists = {} if @entries_lists.blank?
  @entries_lists[@user] = [] if @entries_lists[@user].blank?
  @entries_list = @entries_lists[@user]
  @entries_list.each do |item|
    term = item['term'].presence || ''
    definition = item['definition'].presence || ''
    log "#{term} | #{definition}"
  end
end

Then('the environment matches that set') do
  require 'socket'
  log  "Hostname       : #{Socket.gethostname}"
  log  "Git branch     : #{`git rev-parse --abbrev-ref HEAD`}"
  log  "Input RAILS_ENV: #{ENV['RAILS_ENV']}"
  log  "Rails.env      : #{Rails.env}"
  ENV['RAILS_ENV'].should eq Rails.env
end

Then('the AWS keys are available') do
  Rails.application.credentials.aws.access_key_id.should_not be_blank
  Rails.application.credentials.aws.secret_access_key.should_not be_blank
  Rails.application.credentials.aws.region.should_not be_blank
  Rails.application.credentials.aws.s3_bucket_name.should_not be_blank
end

Then('we artificially fail for info') do
  true.should eq(false ), 'Test commandeered to document meta-test information'
end

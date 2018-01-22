# frozen_string_literal: true

require 'machinist/active_record'
require 'forgery'

# Blueprints
User.blueprint do
  first_name { Forgery::Name.first_name }
  last_name { Forgery::Name.last_name }
  password { 'password' }
  password_confirmation { 'password' }
  email { Forgery::Internet.email_address }
  timezone { 'UTC' }
  theme_id { 1 }
  anon_first_name { Forgery::Name.first_name }
  anon_last_name { Forgery::Name.last_name }
end

Project.blueprint do
  name { Forgery::Name.industry + ' Project' }
  start_dow { 1 }
  end_dow { 2 }
  active { false }
  start_date { DateTime.yesterday }
  end_date { DateTime.tomorrow }
  anon_name { "#{rand < rand ? Forgery::Address.country :
    Forgery::Name.location} #{Forgery::Name.job_title}" }
end

Course.blueprint do
  school_id { 1 }
  name { Forgery::Name.industry + ' Course' }
  number { Forgery::Basic.number }
  timezone { 'UTC' }
  start_date { 4.months.ago }
  end_date { 2.months.from_now }
  anon_name { "TESTING #{Forgery::Name.industry}" }
  anon_number { "GEO-#{rand(100..700)}" }
end

Group.blueprint do
  name { Forgery::Basic.text + ' Group' }
  anon_name { "#{Forgery::Personal.language} Group" }
end

Factor.blueprint do
  name { "#{Forgery::Address.street_number}-#{Forgery::Name.industry} Factor" }
  description { Forgery::Basic.text }
end

FactorPack.blueprint do
  name { "#{Forgery::Name.industry}-#{Forgery::Basic.color} Factor Pack" }
  description { Forgery::Basic.text }
end

ConsentForm.blueprint do
  name { Forgery::Name.location }
end

Experience.blueprint do
  name { Forgery::Name.industry + ' Experience' }
  start_date { DateTime.yesterday }
  end_date { DateTime.tomorrow }
  active { false }
  anon_name { Forgery::Name.company_name.to_s }
end

BingoGame.blueprint do
  topic { Forgery::Name.industry + ' Topic' }
  description { Forgery::Basic.text }
  start_date { DateTime.yesterday }
  end_date { DateTime.tomorrow }
  lead_time { 2 }
  individual_count { 20 }
  group_discount { 0 }
  group_option { false }
  active { false }
  anon_topic { "#{Forgery::Name.company_name} #{Forgery::Name.job_title}" }
end

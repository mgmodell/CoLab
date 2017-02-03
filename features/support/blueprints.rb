require 'machinist/active_record'
require 'forgery'

# Blueprints
User.blueprint do
  first_name { Forgery::Name.first_name }
  last_name { Forgery::Name.last_name }
  password { 'password' }
  password_confirmation { 'password' }
  email { Forgery::Basic.text + '@mailinator.com' }
  timezone { 'UTC' }
end

Project.blueprint do
  name { Forgery::Name.industry + ' Project' }
  start_dow { 1 }
  end_dow { 2 }
  active { false }
  start_date { DateTime.yesterday }
  end_date { DateTime.tomorrow }
end

Course.blueprint do
  school_id { 1 }
  name { Forgery::Name.industry + ' Course' }
  number { Forgery::Basic.number }
  timezone { 'UTC' }
  start_date { 4.months.ago }
  end_date { 2.months.from_now }
end

Group.blueprint do
  name { Forgery::Basic.text + ' Group' }
end

Factor.blueprint do
  name { Forgery::Name.industry + ' Factor' }
  description { Forgery::Basic.text }
end

FactorPack.blueprint do
  name { Forgery::Name.industry + ' Factor Pack' }
  description { Forgery::Basic.text }
end

ConsentForm.blueprint do
  name { Forgery::Name.location }
end

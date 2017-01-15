require 'machinist/active_record'
require 'forgery'

#Blueprints
User.blueprint do
  first_name { Forgery::Name.first_name }
  last_name { Forgery::Name.last_name }
  password { "password" }
  password_confirmation { "password"  }
  email { Forgery::Basic.text +  "@mailinator.com"  }
end

Project.blueprint do
  name { Forgery::Name.industry + " Project" }
  start_dow { 1 }
  end_dow { 2 }
  active { false }
  start_date { Date.yesterday }
  end_date { Date.tomorrow }
end

Course.blueprint do
  school_id { 1 }
  name { Forgery::Name.industry + " Course" }
  number { Forgery::Basic.number }
end

Group.blueprint do
  name { Forgery::Basic.text + " Group" }
end

Behaviour.blueprint do
  name { Forgery::Name.industry + " Behaviour" }
  description { Forgery::Basic.text }
end

ConsentForm.blueprint do
  name {Forgery::Name.location }
end

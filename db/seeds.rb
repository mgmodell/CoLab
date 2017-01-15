# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)

#Foundational data
Behaviour.create( :name => 'Organizing', :description => 'Helped to organize the group''s members and activities.' )
Behaviour.create( :name => 'Understanding requirements', :description => 'Understanding what was required of the group and of the individual group members.')
Behaviour.create( :name => 'Suggesting ideas', :description => 'Suggesting ideas upon which the group could act or continue to build productively.')
Behaviour.create( :name => 'Producing', :description => 'Coming up with something useful to contribute to the group''s efforts.' )
Behaviour.create( :name => 'Performing tasks', :description => 'Performing tasks allocated by the group within the specified timeframe.' )

Role.create( :name => "Instructor",
    :description => "This user teaches the course." )
Role.create( :name => "Graduate Assistant",
    :description => "This user assists the course instructor." )
Role.create( :name => "Student",
    :description => "This user is a student in this class." )

AgeRange.create( :name => "<18" )
AgeRange.create( :name => "18-20" )
AgeRange.create( :name => "21-25" )
AgeRange.create( :name => "25-30" )
AgeRange.create( :name => "31+" )
AgeRange.create( :name => "I'd prefer not to answer" )

GroupProjectCount.create( :name => "none",
  :description => "I don't remember having been a part of a long-term group project." )
GroupProjectCount.create( :name => "few",
  :description => "I have been a part of one to five long-term group projects." )
GroupProjectCount.create( :name => "some",
  :description => "I have been a part of five to ten long-term group projects." )
GroupProjectCount.create( :name => "many",
  :description => "I have been a part of more than 10 long-term group projects." )

Gender.create( :name => "Male" )
Gender.create( :name => "Female" )
Gender.create( :name => "I'd prefer not to answer" )

School.create( :name => 'Indiana University', :description => 'A large, Midwestern university' )
School.create( :name => 'SUNY Korea', :description => 'The State University of New York, Korea' )

Style.create( :name => 'Default', :filename => 'new' )
Style.create( :name => 'Sliders (simple)', :filename => 'slider_basic' )
Style.create( :name => 'buttons (simple)', :filename => 'button_basic' )

u = User.new( :first_name => 'Micah',
  :last_name => 'Modell',
  :admin => true,
  :password => "testest",
  :password_confirmation => "testest",
  :email => 'micah.modell@gmail.com' )
u.skip_confirmation!
u.save


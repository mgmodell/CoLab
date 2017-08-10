# frozen_string_literal: true
Then /^the group's diversity score is (\d+)$/ do |ds|
  @group.diversity_score.should eq ds.to_i
end

Then /^we update the group's diversity score$/ do
  @group.calc_diversity_score
  @group.save
end

Then /^the score calculated from the users is (\d+)$/ do |ds|
  emails_list = @users.collect(&:email)
  Group.calc_diversity_score_for_proposed_group(emails:emails_list.join(', ')).should eq ds.to_i
end

Then /^we add the users to the group$/ do
  @users.each do |user|
    @group.users << user
  end
  @group.save

end

Then /^the "([^"]*)" of the "([^"]*)" "([^"]*)" user is "([^"]*)"$/ do |demographic, ordinal, type, code|
  users = []
  case type
  when 'group'
    users = @group.users
  when 'loose'
    users = @users
  else
    puts "There's no such thing as a '#{type}' user"
    pending
  end

  u = nil
  case ordinal
  when 'first'
    u = users.first
  when 'second'
    u = users[1]
  when 'third'
    u = users[2]
  when 'fourth'
    u = users[3]
  when 'last'
    u = users.last
  when 'random'
    u = users[rand(users.count) - 1]
  else
    puts "There's no such thing as a '#{ordinal}' user"
    pending
  end

  case demographic
  when 'cip'
    u.cip_code = CipCode.where(gov_code: code).take
  when 'gender'
    u.gender = Gender.where(code: code).take
  when 'language'
    u.primary_language = Language.where(code: code).take
  when 'uni_date'
    u.started_school = Chronic.parse code
  when 'dob'
    u.date_of_birth = Chronic.parse code
  else
    puts "#{demographic} is not an available demographic"
    pending
  end
  u.save

end

Given /^the "([^"]*)" "([^"]*)" user is from "([^"]*)" in "([^"]*)"$/  do |ordinal, type, state, country|
  users = []
  case type
  when 'group'
    users = @group.users
  when 'loose'
    users = @users
  else
    puts "There's no such thing as a '#{type}' user"
    pending
  end

  u = nil
  case ordinal
  when 'first'
    u = users.first
  when 'second'
    u = users[1]
  when 'third'
    u = users[2]
  when 'fourth'
    u = users[3]
  when 'last'
    u = users.last
  when 'random'
    u = users[rand(users.count) - 1]
  else
    puts "There's no such thing as a '#{ordinal}' user"
    pending
  end

  u.home_state = HomeState.where( code: "#{state}:#{country}" ).take
  pending if state.nil?
  u.save
end

Then /^we remove the "([^"]*)" user$/ do |ordinal|
  case ordinal
  when 'first'
    @group.users.delete(  @group.users[ 0 ] )
  when 'second'
    @group.users.delete(  @group.users[ 1 ] )
  when 'third'
    @group.users.delete(  @group.users[ 2 ] )
  when 'fourth'
    @group.users.delete(  @group.users[ 3 ] )
  when 'last'
    @group.users.delete(  @group.users[ 4 ] )
  when 'random'
    @group.users.delete(  @group.users.sample )
  else
    puts "There's no such thing as a '#{ordinal}' user"
    pending
  end
  @group.save
end

Then /^the "([^"]*)" "([^"]*)" user is added to the group$/ do |ordinal,type|
  case ordinal
  when 'first'
    @group.users << @users[ 0 ] 
  when 'second'
    @group.users <<  @users[ 1 ] 
  when 'third'
    @group.users <<  @users[ 2 ]
  when 'fourth'
    @group.users <<  @users[ 3 ]
  when 'last'
    @group.users <<  @users[ 4 ]
  when 'random'
    @group.users <<  @users.sample
  else
    puts "There's no such thing as a '#{ordinal}' user"
    pending
  end
  @group.save
end

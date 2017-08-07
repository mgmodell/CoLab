Then /^the group's diversity score is (\d+)$/  do |ds|
  @group.diversity_score.should eq ds.to_i
end

Then /^we update the group's diversity score$/  do
  @group.calc_diversity_score
end

Then /^the score calculated from the users is (\d+)$/  do |ds|
  emails_list = @users.collect{ |user| user.email }
  Group.calc_diversity_score_for_proposed_group( emails_list.join( ', ' ) ).should eq ds.to_i
end

Then /^the "([^"]*)" of the "([^"]*)" user is "([^"]*)"$/) do |demographic, ordinal, code|
  u = nil
  case ordinal
  when 'first'
    u = @users.first
  when 'second'
    u = @users[ 1 ]
  when 'third'
    u = @users[ 2 ]
  when 'fourth'
    u = @users[ 3 ]
  when 'last'
    u = @users.last
  when 'random'
    u = @users[ rand( @users.count ) - 1 ]
  else
    puts "There's no such thing as a '#{ordinal}' user"
    pending
  end

  case demographic
  when 'cip'
    u.cip_code = CipCode.where( code: code )
  when 'gender'
    u.gender = Gender.where( code: code )
  when 'language'
    u.primary_language = Language.where( code: code )
  when 'uni_year'
    u.started_school = Chronic.parse code
  when 'dob'
    u.date_of_birth = Chronic.parse code
  else
    puts "#{demographic} is not an available demographic"
    pending
  end
  u.save
end


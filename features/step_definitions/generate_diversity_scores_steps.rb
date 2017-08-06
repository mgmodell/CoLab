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

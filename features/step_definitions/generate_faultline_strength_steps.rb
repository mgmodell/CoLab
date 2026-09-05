# frozen_string_literal: true

When( /^we update the group's faultline strength$/ ) do
  @faultline_strength = @group.calc_faultline_strength
end

Then( /^the group's faultline strength is (\d+(?:\.\d+)?)$/ ) do | score |
  @faultline_strength.should be_within( 0.0001 ).of( score.to_f )
end

Then( /^the group's faultline strength is greater than (\d+(?:\.\d+)?)$/ ) do | score |
  @faultline_strength.should > score.to_f
end

Then( /^the normalized proposed-group faultline score matches the group's users$/ ) do
  baseline = Group.calc_faultline_strength_for_group( users: @group.users )
  messy_emails = @users.map { | user | " #{user.email.upcase} " }
                       .push( @users.first.email )
                       .push( ' ' )
                       .join( ', ' )

  normalized_score = Group.calc_faultline_strength_for_proposed_group( emails: messy_emails )
  normalized_score.should be_within( 0.0001 ).of( baseline )
end

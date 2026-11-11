# frozen_string_literal: true

Given( 'the user has a registered push device' ) do
  @user.push_devices.create!( platform: 'google', token: 'test-token' )
end

When( 'a push notification is sent to the user' ) do
  @pushed = []
  allow_any_instance_of( ApplicationPushNotification ).to receive( :deliver_later_to ) do | _n, devices |
    @pushed.concat( devices )
  end
  PushNotifier.notify( @user, title: 'CoLab', body: I18n.t( 'notifications.pending_activities' ) )
end

Then( "the user's device should be sent a push notification" ) do
  expect( @pushed.map( &:token ) ).to eq( ['test-token'] )
end

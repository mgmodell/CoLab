# frozen_string_literal: true

namespace :mobile do
  desc 'Create (or reset) the user the mobile end-to-end tests log in as'
  task :seed_e2e, %i[email password] => [:environment] do | _t, args |
    abort 'Refusing to seed an e2e user in production' if Rails.env.production?

    email = args[:email].presence || ENV.fetch( 'E2E_EMAIL', 'mobile_e2e@example.com' )
    password = args[:password].presence || ENV.fetch( 'E2E_PASSWORD', 'password' )

    user = User.joins( :emails ).find_by( emails: { email: email } )
    if user.nil?
      user = User.new(
        first_name: 'Mobile',
        last_name: 'Tester',
        email: email,
        password: password,
        password_confirmation: password,
        welcomed: true,
        school: School.first,
        timezone: 'UTC'
      )
      user.skip_confirmation!
    else
      user.password = password
      user.password_confirmation = password
    end

    abort user.errors.full_messages.join( ', ' ) unless user.save
    puts "E2E user ready: #{email}"
  end
end

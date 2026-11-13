# Box 1 (IDOR: Student Records) - EMBED a classic account IDOR into CoLab's real
# profile page. Training platform: deliberately vulnerable, rendered by CoLab's
# own SPA profile screen. Modifies EXISTING code in place (home#index +
# get_profile_hash); no new route, no fabricated page, no frontend rebuild.
#   ruby /tmp/patch_profile_idor.rb   (inside sec_env-app-1), then restart app.
Dir.chdir('/app')
path = 'app/controllers/home_controller.rb'
c = File.read(path)

if c.include?('idor_view_student')
  puts 'already patched'
else
  new_index = <<-'RUBY'
  def index
    # CTF training: the profile page TRUSTS the student number in the URL and
    # shows that account with NO ownership check -> classic IDOR to practice.
    if params[:student].present?
      viewed = User.joins( :emails ).find_by( emails: { email: "student#{params[:student].to_i}@idor.local" } )
      session[:idor_view_student] = viewed&.id
    else
      session.delete( :idor_view_student )
    end
  end
RUBY

  new_gph = <<-'RUBY'
  def get_profile_hash
    viewed = current_user
    if session[:idor_view_student].present?
      v = User.find_by( id: session[:idor_view_student] )   # IDOR: no ownership check
      viewed = v if v
    end
    profile_hash = {
      user: viewed.as_json(
        only: %i[ id first_name last_name gender_id country
                  timezone theme school_id language_id
                  date_of_birth home_state_id cip_code_id
                  primary_language_id started_school researcher
                  impairment_visual impairment_auditory
                  impairment_motor impairment_cognitive
                  impairment_other primary_language_id
                  welcomed ]
      )
    }
    profile_hash[:user][:is_instructor] = current_user.is_instructor?
    profile_hash[:user][:is_admin] = current_user.is_admin?
    profile_hash[:user][:name] = viewed.name( false )
    profile_hash[:user][:emails] = viewed.emails.as_json(
      only: %i[id email primary],
      methods: ['confirmed?']
    )
    profile_hash
  end
RUBY

  c2 = c.sub(/  def index; end\n/, new_index)
  c2 = c2.sub(/  def get_profile_hash.*?\n  end\n/m, new_gph)
  File.write(path, c2)
  ok = File.read(path)
  puts 'patched index: ' + ok.include?('idor_view_student').to_s
  puts 'patched gph:   ' + ok.include?('viewed.as_json').to_s
end

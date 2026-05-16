# Be sure to restart your server when you modify this file.

# Rails.application.config.session_store :cookie_store, key: '_colab_session'
#
# SameSite=None; Secure is required for LTI 1.3 compatibility.
# The LTI OIDC flow ends with a cross-site form POST from the LMS
# (e.g. Moodle) back to CoLab's /lti/launch.  With SameSite=Lax
# (the Rails default) the browser does not include the session cookie
# on cross-site POSTs, so session[:lti_state] is nil at launch and
# the state-mismatch check fails with 401.  Setting SameSite=None
# (which requires Secure=true) restores cookie delivery on these
# cross-site POSTs.  The app already skips CSRF verification so this
# does not weaken any existing CSRF protection.  secure: true is
# suppressed in the test environment because test requests run over
# plain HTTP; development always uses HTTPS (app:3443) so secure: true
# is safe there.
Rails.application.config.session_store :active_record_store,
                                        same_site: :none,
                                        secure: !Rails.env.test?

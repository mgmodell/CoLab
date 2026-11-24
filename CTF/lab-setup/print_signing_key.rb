# Print the LTI deep-link signing key the live app uses (derived from
# secret_key_base). Written by apply-embeds.ps1 to CTF/state/lti_signing_key.hex
# so the toolbox forge helpers (boxes 9/10) sign tokens the app accepts even if
# the container's SECRET_KEY_BASE changes on a full recreate.
v = Rails.application.message_verifier(:lti_deep_link_flow)
key = v.instance_variable_get(:@secret)
digest = v.instance_variable_get(:@digest)
STDOUT.write("#{key.unpack1('H*')} #{digest}")

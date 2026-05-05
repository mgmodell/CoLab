# This configuration file will be evaluated by Puma. The top-level methods that
# are invoked here are part of Puma's configuration DSL. For more information
# about methods provided by the DSL, see https://puma.io/puma/Puma/DSL.html.
#
# Puma starts a configurable number of processes (workers) and each process
# serves each request in a thread from an internal thread pool.
#
# You can control the number of workers using ENV["WEB_CONCURRENCY"]. You
# should only set this value when you want to run 2 or more workers. The
# default is already 1. You can set it to `auto` to automatically start a worker
# for each available processor.
#
# The ideal number of threads per worker depends both on how much time the
# application spends waiting for IO operations and on how much you wish to
# prioritize throughput over latency.
#
# As a rule of thumb, increasing the number of threads will increase how much
# traffic a given process can handle (throughput), but due to CRuby's
# Global VM Lock (GVL) it has diminishing returns and will degrade the
# response time (latency) of the application.
#
# The default is set to 3 threads as it's deemed a decent compromise between
# throughput and latency for the average Rails application.
#
# Any libraries that use a connection pool or another resource pool should
# be configured to provide at least as many connections as the number of
# threads. This includes Active Record's `pool` parameter in `database.yml`.
threads_count = ENV.fetch("RAILS_MAX_THREADS", 3)
threads threads_count, threads_count

# In development you can start the server with HTTPS by setting COLAB_HTTPS=true
# (e.g. via Procfile.dev-https or `COLAB_HTTPS=true dev_serv.sh -t`).
# A self-signed certificate is generated on first run using Ruby's built-in
# OpenSSL and cached in tmp/ssl/.  Add a browser exception once per machine.
if ENV['COLAB_HTTPS'] == 'true'
  require 'openssl'
  require 'fileutils'
  require 'socket'

  _ssl_dir  = File.expand_path('../tmp/ssl', __dir__)
  _key_path = File.join(_ssl_dir, 'dev.key')
  _crt_path = File.join(_ssl_dir, 'dev.crt')

  # Build the SAN list for the self-signed cert.
  #
  # Always includes:
  #   DNS:localhost, IP:127.0.0.1, DNS:app   (Docker Compose service name)
  #
  # Also includes the container's real hostname (e.g. dev-serv-mymachine) so
  # that a VNC browser container or Moodle can reach CoLab via both
  # `https://app:3443` and `https://<hostname>:3443` without TLS warnings.
  #
  # Add extra names/IPs via COLAB_SSL_HOSTS (comma-separated).
  # Bare IPs are automatically prefixed with "IP:", hostnames with "DNS:".
  #
  # To force cert regeneration (e.g. after changing COLAB_SSL_HOSTS or after
  # the container hostname changes), delete tmp/ssl/ and restart.
  _base_sans  = %w[DNS:localhost IP:127.0.0.1 DNS:app]
  begin
    _container_host = Socket.gethostname
    if _container_host && !_container_host.empty? &&
       _container_host != 'localhost' && _container_host != 'app'
      _base_sans << "DNS:#{_container_host}"
    end
  rescue StandardError
    # hostname lookup failed; proceed without it
  end
  _extra_sans = ENV.fetch('COLAB_SSL_HOSTS', '').split(',').map(&:strip).reject(&:empty?).map do |h|
    begin
      require 'ipaddr'
      IPAddr.new(h).ipv4? ? "IP:#{h}" : "DNS:#{h}"
    rescue IPAddr::InvalidAddressError, IPAddr::AddressFamilyError
      "DNS:#{h}"
    end
  end
  _desired_sans = (_base_sans + _extra_sans).uniq

  # Regenerate the cert when it is missing OR when its SANs no longer match
  # the desired set (e.g. after the hostname or COLAB_SSL_HOSTS changes).
  # OpenSSL serialises SANs as "DNS:foo, IP:1.2.3.4" (space after comma);
  # normalise both sides to a sorted array for a reliable comparison.
  def _san_to_sorted_set(san_string)
    san_string.to_s.split(',').map(&:strip).sort
  end

  _need_regen = !File.exist?(_key_path) || !File.exist?(_crt_path)
  unless _need_regen
    begin
      _existing = OpenSSL::X509::Certificate.new(File.read(_crt_path))
      _existing_san = _existing.extensions.find { |e| e.oid == 'subjectAltName' }&.value.to_s
      _need_regen = _san_to_sorted_set(_existing_san) != _san_to_sorted_set(_desired_sans.join(','))
    rescue OpenSSL::X509::CertificateError
      _need_regen = true
    end
  end

  if _need_regen
    FileUtils.mkdir_p(_ssl_dir)

    _key           = OpenSSL::PKey::RSA.generate(2048)
    _cert          = OpenSSL::X509::Certificate.new
    _name          = OpenSSL::X509::Name.parse('/CN=localhost')
    _cert.subject  = _name
    _cert.issuer   = _name
    _cert.not_before = Time.now
    _cert.not_after  = Time.now + 365 * 24 * 60 * 60
    _cert.public_key = _key.public_key
    _cert.serial   = 1
    _cert.version  = 2

    _ef = OpenSSL::X509::ExtensionFactory.new
    _ef.subject_certificate = _cert
    _ef.issuer_certificate  = _cert
    _cert.add_extension(
      _ef.create_extension('subjectAltName', _desired_sans.join(','), false)
    )
    _cert.sign(_key, OpenSSL::Digest::SHA256.new)

    File.write(_key_path, _key.to_pem)
    File.write(_crt_path, _cert.to_pem)
    File.chmod(0o600, _key_path)
    $stdout.puts "Generated self-signed TLS certificate in #{_ssl_dir}"
    $stdout.puts "  SANs: #{_desired_sans.join(', ')}"
  end

  # Bind HTTPS only; no plain-HTTP listener in this mode.
  ssl_bind '0.0.0.0', Integer(ENV.fetch('PORT', 3443)), {
    key:         _key_path,
    cert:        _crt_path,
    verify_mode: 'none'
  }
else
  # Specifies the `port` that Puma will listen on to receive requests; default is 3000.
  port ENV.fetch("PORT", 3000)
end

# Allow puma to be restarted by `bin/rails restart` command.
plugin :tmp_restart

# Run the Solid Queue supervisor inside of Puma for single-server deployments.
plugin :solid_queue if ENV["SOLID_QUEUE_IN_PUMA"]

# Specify the PID file. Defaults to tmp/pids/server.pid in development.
# In other environments, only set the PID file if requested.
pidfile ENV["PIDFILE"] if ENV["PIDFILE"]

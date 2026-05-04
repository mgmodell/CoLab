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

  _ssl_dir  = File.expand_path('../tmp/ssl', __dir__)
  _key_path = File.join(_ssl_dir, 'dev.key')
  _crt_path = File.join(_ssl_dir, 'dev.crt')

  unless File.exist?(_key_path) && File.exist?(_crt_path)
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
      _ef.create_extension('subjectAltName',
                           'DNS:localhost,IP:127.0.0.1,DNS:app', false)
    )
    _cert.sign(_key, OpenSSL::Digest::SHA256.new)

    File.write(_key_path, _key.to_pem)
    File.write(_crt_path, _cert.to_pem)
    $stdout.puts "Generated self-signed TLS certificate in #{_ssl_dir}"
  end

  # Bind HTTPS only; no plain-HTTP listener in this mode.
  ssl_bind '0.0.0.0', ENV.fetch('PORT', 3443).to_i, {
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

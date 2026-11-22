require 'minitest/autorun'
require 'erb'
require 'fileutils'
require 'open3'
require 'shellwords'
require 'tmpdir'
require 'yaml'

class CucumberReportTest < Minitest::Test
  CONFIG = File.expand_path('../config/cucumber.yml', __dir__)

  def setup
    @environment = ENV.to_h
    ENV.delete('CUCUMBER_HTML_REPORT_ENABLED')
    ENV.delete('CUCUMBER_HTML_REPORT')
    ENV.delete('CUCUMBER_FORMAT')
    @directory = Dir.mktmpdir
    @original_directory = Dir.pwd
    Dir.chdir(@directory)
  end

  def teardown
    Dir.chdir(@original_directory)
    ENV.replace(@environment)
    FileUtils.remove_entry(@directory)
  end

  def profiles
    YAML.safe_load(ERB.new(File.read(CONFIG)).result)
  end

  def test_html_is_disabled_by_default
    %w[default rerun].each do |profile|
      refute_includes Shellwords.split(profiles.fetch(profile)), 'html'
    end
  end

  def test_html_is_added_to_both_profiles_without_losing_existing_formatters
    ENV['CUCUMBER_HTML_REPORT_ENABLED'] = 'true'
    ENV['CUCUMBER_HTML_REPORT'] = 'reports/test report.html'
    File.write('rerun.txt', 'features/example.feature:12')

    %w[default rerun].each do |profile|
      options = Shellwords.split(profiles.fetch(profile))
      html = options.index('html')
      assert_equal '--format', options[html - 1]
      assert_equal ['--out', 'reports/test report.html'], options[html + 1, 2]
      assert_includes options, profile == 'default' ? 'pretty' : 'rerun'
    end
    assert_includes Shellwords.split(profiles.fetch('rerun')), 'features/example.feature:12'
  end

  def test_default_report_path_with_an_empty_rerun
    ENV['CUCUMBER_HTML_REPORT_ENABLED'] = 'true'
    options = Shellwords.split(profiles.fetch('rerun'))
    assert_includes options, 'reports/cucumber_report.html'
    assert_includes options, 'features'
    assert_includes options, 'progress'
  end

  def test_test_runner_enables_html_only_with_uppercase_f
    app = File.join(@directory, 'src/app')
    bin = File.join(@directory, 'bin')
    FileUtils.mkdir_p([app, bin])
    %w[git mise bundle yarn].each do |command|
      File.write(File.join(bin, command), "#!/bin/bash\nexit 0\n")
      File.chmod(0o755, File.join(bin, command))
    end
    rails = File.join(bin, 'rails')
    File.write(rails, "#!/bin/bash\nprintf '%s\\n' \"${CUCUMBER_HTML_REPORT_ENABLED:-unset}\" \"$@\" > \"$HOME/rails-arguments\"\n")
    File.chmod(0o755, rails)
    runner = File.expand_path('../containers/test_env/run_cukes.sh', __dir__)
    env = { 'HOME' => @directory, 'PATH' => "#{bin}:#{ENV.fetch('PATH')}",
            'CUCUMBER_HTML_REPORT_ENABLED' => nil }

    [
      [%w[-f features/example.feature], 'unset', 'cucumber'],
      [%w[-f features/example.feature -F], 'true', 'cucumber'],
      [%w[-F -f features/example.feature], 'true', 'cucumber'],
      [%w[-r], 'unset', 'cucumber:rerun'],
      [%w[-r -F], 'true', 'cucumber:rerun']
    ].each do |args, expected_html, expected_task|
      output, status = Open3.capture2e(env, 'bash', runner, *args)
      assert status.success?, output
      arguments = File.readlines(File.join(@directory, 'rails-arguments'), chomp: true)
      assert_equal expected_html, arguments[0], args.inspect
      assert_equal expected_task, arguments[1], args.inspect
      assert_includes arguments, 'FEATURE=features/example.feature' if args.include?('-f')
    end
  end
end

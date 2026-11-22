require 'minitest/autorun'
require 'erb'
require 'fileutils'
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
end

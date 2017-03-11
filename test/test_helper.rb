require 'minitest/autorun'

require 'bundler/setup'
require 'capybara/dsl'
require 'rack/file'
require 'html-proofer'

def build_dir
  File.join(File.dirname(__FILE__), '_site')
end

Capybara.app = Rack::File.new(build_dir)

class CapybaraTestCase < MiniTest::Test
  include Capybara::DSL

  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end

def before_run
  before = Time.now
  puts 'Building site..'
  `jekyll build -d #{build_dir} -V` unless File.directory?('test/_site')
  puts "Finished building site in #{Time.now - before}s\n\n"
  opts = {
    url_ignore: [/localhost/],
    empty_alt_ignore: true,
    file_ignore: [/slides/]
  }
  HTMLProofer.check_directory(build_dir, opts).run
end

before_run

MiniTest.after_run do
  `rm -rf #{build_dir}`
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
ENV['RACK_ENV'] = 'test'

require 'newznab/api'
require 'minitest/autorun'
require 'faker'

require 'minitest/reporters'
MiniTest::Reporters.use!

require 'minitest-vcr'
VCR.configure do |c|
  c.cassette_library_dir = 'test/cassettes'
  c.hook_into :webmock
end
MinitestVcr::Spec.configure!

module Minitest::Assertions
  def assert_nothing_raised(*)
    yield
  end
end

class Minitest::Test

  # Helper to create a default newznab api using env's
  def newznab
    @newz ||= Newznab::Api.new(uri: 'https://api.newznab.com', key: '7e8896464895c1cde33759b8307f5cf8')
  end

  def before_setup
    VCR.insert_cassette File.join(self.class.to_s, name)
  end

  def after_teardown
    VCR.eject_cassette
  end
end
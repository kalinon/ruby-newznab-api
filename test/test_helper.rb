$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
ENV['RACK_ENV'] = 'test'

require 'newznab/api'
require 'minitest/autorun'
require 'minitest/reporters'
require 'faker'

MiniTest::Reporters.use!

module Minitest::Assertions
  def assert_nothing_raised(*)
    yield
  end
end
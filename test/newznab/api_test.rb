require 'test_helper'
require 'newznab/api'

class Newznab::ApiTest < Minitest::Test

  def test_that_it_has_a_version_number
    refute_nil ::Newznab::Api::VERSION
  end

  def test_api_object
    uri = Faker::Internet.url
    key = Faker::Internet.password(10)

    newz = Newznab::Api.new(uri: uri, key: key)
    refute_nil newz

    refute_empty newz.api_uri
    refute_empty newz.api_key
    assert_equal uri, newz.api_uri
    assert_equal key, newz.api_key
  end

  def test_default_env
    refute_empty ENV['NEWZNAB_URI']
    refute_empty ENV['NEWZNAB_API_KEY']

    newz = Newznab::Api.new
    refute_nil newz

    refute_empty newz.api_uri
    refute_empty newz.api_key
    assert_equal ENV['NEWZNAB_URI'], newz.api_uri
    assert_equal ENV['NEWZNAB_API_KEY'], newz.api_key
  end

  def test_api_timeout
    newz = Newznab::Api.new
    refute_nil newz
    assert_equal 10, newz.api_timeout, 'Default timeout'
    newz.api_timeout = 2
    assert_equal 2, newz.api_timeout, 'Change timeout to 2'
  end

  def test_api_caps
    refute_nil newznab
    assert_nothing_raised do
      response = newznab.caps
      refute_nil response

      assert response.has_key? 'server'
      assert response.has_key? 'limits'
      assert response.has_key? 'registration'
      assert response.has_key? 'searching'
      assert response.has_key? 'categories'
      assert response.has_key? 'groups'
      assert response.has_key? 'genres'
    end
  end

  def test_not_supported
    assert_raises Newznab::Api::FunctionNotSupportedError do
      newznab.get(api_function: :unsupported)
    end
  end

  # FIXME
  # def test_details
  #   guid = '8610de2d24383b1efd513da1b30e96b5'
  #
  #   assert_raises Newznab::Api::FunctionDisabledError do
  #     newznab.get_details(guid)
  #   end
  # end
  #
  # def test_nfo
  #   guid = '8610de2d24383b1efd513da1b30e96b5'
  #
  #   assert_raises Newznab::Api::FunctionDisabledError do
  #     newznab.get_nfo(guid)
  #   end
  # end

  def test_disabled_function
    guid = '8610de2d24383b1efd513da1b30e96b5'

    assert_raises Newznab::Api::FunctionDisabledError do
      newznab.get_details(guid)
    end

    assert_raises Newznab::Api::FunctionDisabledError do
      newznab.get_nfo(guid)
    end
  end

end

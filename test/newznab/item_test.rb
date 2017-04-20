require 'test_helper'
require 'newznab/api'

class Newznab::ItemTest < Minitest::Test

  def test_single_item_conversion
    item = newznab.tv_search(query: 'This Old House', extended: true, limit: 1).first
    refute_nil item
    assert_kind_of Newznab::Item, item

    refute_nil item.title
    refute_nil item.guid
    refute_nil item.link
    refute_nil item.pub_date
    refute_nil item.description
    refute_nil item.metadata
  end

  def test_multiple_item_conversion
    resp = newznab.tv_search(query: 'This Old House', extended: true, limit: 10)
    refute_nil resp.first
    assert_kind_of Newznab::Item, resp.first
    resp.each { |o| assert_kind_of Newznab::Item, o }
    assert_equal 10, resp.count
  end

  def test_missing_method
    item = newznab.tv_search(query: 'This Old House', extended: true, limit: 1).first

    assert item.respond_to? :category
    refute_nil item.metadata['category']
    assert_equal item.metadata['category'], item.category

    assert item.respond_to? :url
    refute_nil item.url

    assert item.respond_to? :length
    refute_nil item.length

    assert item.respond_to? :type
    refute_nil item.type
  end

end
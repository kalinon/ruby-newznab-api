require 'test_helper'
require 'newznab/api'

class Newznab::ListTest < Minitest::Test

  def test_search_results
    resp = newznab.tv_search(query: 'This Old House', extended: true, limit: 10)
    assert_kind_of Newznab::SearchResults, resp, 'Is a Newznab::SearchResults'
    refute_nil resp, 'Response is not empty'
    assert_equal 10, resp.count, 'Response count equals limit'
    refute_nil resp.first
    refute_nil resp.last

    count = 0
    assert_nothing_raised do
      resp.each do
        count += 1
      end
    end
    assert_equal 10, count
    assert_equal 844, resp.total_count
    assert_equal 0, resp.offset
    assert resp.has_more?
    assert_equal 1, resp.page
    assert_equal 85, resp.total_pages
  end

  def test_search_results_offset
    resp = newznab.tv_search(query: 'This Old House', extended: true, limit: 10, offset: 50)
    assert_kind_of Newznab::SearchResults, resp, 'Is a Newznab::SearchResults'
    refute_nil resp, 'Response is not empty'
    assert_equal 10, resp.count, 'Response count equals limit'
    refute_nil resp.first
    refute_nil resp.last

    count = 0
    assert_nothing_raised do
      resp.each do
        count += 1
      end
    end
    assert_equal 10, count

    assert_equal 844, resp.total_count
    assert_equal 50, resp.offset
    assert resp.has_more?
    assert_equal 6, resp.page
    assert_equal 85, resp.total_pages
  end

  def test_method_missing
    refute_nil newznab
    assert_nothing_raised do
      resp = newznab.tv_search(query: 'This Old House', extended: true, limit: 5)
      refute_nil resp, 'Response is not empty'
      assert_equal 5, resp.count, 'Response count equals limit'
      assert_kind_of Newznab::SearchResults, resp, 'Is a Newznab::SearchResults'
      assert resp.version
      assert_equal '2.0', resp.version
    end
  end

  def test_next_page
    resp = newznab.tv_search(query: 'This Old House', extended: true, limit: 10, offset: 50)
    assert_equal 6, resp.page

    assert_nothing_raised do
      resp.next_page!
    end

    assert_equal 844, resp.total_count
    assert_equal 60, resp.offset
    assert resp.has_more?
    assert_equal 7, resp.page
    assert_equal 85, resp.total_pages
  end

  def test_prev_page
    resp = newznab.tv_search(query: 'This Old House', extended: true, limit: 10, offset: 50)
    assert_equal 6, resp.page

    assert_nothing_raised do
      resp.prev_page!
    end

    assert_equal 844, resp.total_count
    assert_equal 40, resp.offset
    assert resp.has_more?
    assert_equal 5, resp.page
    assert_equal 85, resp.total_pages
  end
end

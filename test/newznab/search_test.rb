require 'test_helper'
require 'newznab/api'

class Newznab::SearchTest < Minitest::Test
  def test_search
    refute_nil newznab
    assert_nothing_raised do
      resp = newznab.search(query: 'This Old House', limit: 50)
      refute_nil resp
      assert_equal 50, resp.count
      assert_equal :search, resp.function
    end
  end

  def test_tv_search
    refute_nil newznab
    assert_nothing_raised do
      resp = newznab.tv_search(query: 'This Old House', extended: true, limit: 5)
      refute_nil resp
      assert_equal 5, resp.count
      assert_equal :tvsearch, resp.function

    end
  end

  def test_movie_search
    refute_nil newznab
    assert_nothing_raised do
      resp = newznab.movie_search(query: 'Sparticus', extended: true, limit: 5)
      refute_nil resp
      assert_equal 5, resp.count
      assert_equal :movie, resp.function
    end
  end

  def test_music_search
    refute_nil newznab
    assert_nothing_raised do
      resp = newznab.music_search(query: 'Bach', extended: true, limit: 5)
      refute_nil resp
      assert_equal 5, resp.count
      assert_equal :music, resp.function
    end
  end

  def test_book_search
    refute_nil newznab
    assert_nothing_raised do
      resp = newznab.book_search(query: 'bible', extended: true, limit: 5)
      refute_nil resp
      assert_equal 5, resp.count
      assert_equal :book, resp.function
    end
  end
end

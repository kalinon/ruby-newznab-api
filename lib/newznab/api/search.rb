## Yard Doc generation stuff
# @!macro [new] raise.FunctionNotSupportedError
#   @raise [FunctionNotSupportedError] indicating the resource requested is not supported
# @!macro [new] raise.NewznabAPIError
#   @raise [NewznabAPIError] indicating the api request code received
# @!macro [new] search.params
#   @param query [String] Search input (URL/UTF-8 encoded). Case insensitive.
#   @param group [Array] List of usenet groups to search delimited by ”,”
#   @param limit [Integer] Upper limit for the number of items to be returned.
#   @param cat [Array] List of categories to search delimited by ”,”
#   @param attrs [Array] List of requested extended attributes delimeted by ”,”
#   @param extended [true, false] List all extended attributes (attrs ignored)
#   @param delete [true, false] Delete the item from a users cart on download.
#   @param maxage [Integer] Only return results which were posted to usenet in the last x days.
#   @param offset [Integer] The 0 based query offset defining which part of the response we want.

module Newznab
  module Api
    ##
    # Module to hold search specific functions
    module Search

      ##
      # Perform a search with the provided optional params
      # @macro search.params
      # @return [Newznab::SearchResults]
      # @since 0.1.0
      # @macro raise.NewznabAPIError
      def search(**params)
        args = _parse_search_args(**params)
        Newznab::Api::SearchResults.new(_make_request(:search, **args), :search, args)
      end

      ##
      # Perform a tv-search with the provided optional params
      # @param rid [Integer] TVRage id of the item being queried.
      # @param season [String] Season string, e.g S13 or 13 for the item being queried.
      # @param ep [String] Episode string, e.g E13 or 13 for the item being queried.
      # @macro search.params
      # @macro raise.NewznabAPIError
      # @return [Newznab::SearchResults]
      # @since 0.1.0
      def tv_search(rid: nil, season: nil, ep: nil, **params)
        args = _parse_search_args(**params)

        unless rid.nil?
          args[:rid] = rid.to_s.encode('utf-8')
        end

        unless season.nil?
          args[:season] = season.to_s.encode('utf-8')
        end

        unless ep.nil?
          args[:ep] = ep.to_s.encode('utf-8')
        end

        Newznab::Api::SearchResults.new(_make_request(:tvsearch, **args), :tvsearch, args)
      end

      ##
      # Perform a movie-search with the provided optional params
      # @param imdbid [String] IMDB id of the item being queried e.g. 0058935.
      # @param genre [String] A genre string i.e. ‘Romance’ would match ‘(Comedy, Drama, Indie, Romance)’
      # @macro search.params
      # @macro raise.NewznabAPIError
      # @return [Newznab::SearchResults]
      # @since 0.1.0
      def movie_search(imdbid: nil, genre: nil, **params)
        args = _parse_search_args(**params)

        unless imdbid.nil?
          args[:imdbid] = imdbid.to_s.encode('utf-8')
        end

        unless genre.nil?
          args[:genre] = genre.to_s.encode('utf-8')
        end

        Newznab::Api::SearchResults.new(_make_request(:movie, **args), :movie, args)
      end

      ##
      # Perform a music-search with the provided optional params
      # @param album [String]	Album title (URL/UTF-8 encoded). Case insensitive.
      # @param artist [String] Artist name (URL/UTF-8 encoded). Case insensitive.
      # @param label [String] Publisher/Label name (URL/UTF-8 encoded). Case insensitive.
      # @param track [String] Track name (URL/UTF-8 encoded). Case insensitive.
      # @param year [String] Four digit year of release.
      # @param genre [String] A genre string i.e. ‘Romance’ would match ‘(Comedy, Drama, Indie, Romance)’
      # @macro search.params
      # @macro raise.NewznabAPIError
      # @return [Newznab::SearchResults]
      # @since 0.1.0
      def music_search(album: nil, artist: nil, label: nil, track: nil, year: nil, genre: nil, **params)
        args = _parse_search_args(**params)

        unless album.nil?
          args[:album] = album.to_s.encode('utf-8')
        end

        unless artist.nil?
          args[:artist] = artist.to_s.encode('utf-8')
        end

        unless label.nil?
          args[:label] = label.to_s.encode('utf-8')
        end

        unless track.nil?
          args[:track] = track.to_s.encode('utf-8')
        end

        unless year.nil?
          args[:year] = year.to_s.encode('utf-8')
        end

        unless genre.nil?
          args[:genre] = genre.to_s.encode('utf-8')
        end

        Newznab::Api::SearchResults.new(_make_request(:music, **args), :music, args)
      end

      ##
      # Perform a book-search with the provided optional params
      # @param title [String]	Book title (URL/UTF-8 encoded). Case insensitive.
      # @param author [String] Author name (URL/UTF-8 encoded). Case insensitive.
      # @macro search.params
      # @macro raise.NewznabAPIError
      # @return [Newznab::SearchResults]
      # @since 0.1.0
      def book_search(title: nil, author: nil, **params)
        args = _parse_search_args(**params)

        unless title.nil?
          args[:title] = title.to_s.encode('utf-8')
        end

        unless author.nil?
          args[:author] = author.to_s.encode('utf-8')
        end

        Newznab::Api::SearchResults.new(_make_request(:book, **args), :book, args)
      end


      private

      ##
      # @macro search.params
      # @return [Hash]
      # @since 0.1.0
      def _parse_search_args(query: nil, group: [], limit: nil, cat: [], attrs: [], extended: false, delete: false, maxage: nil, offset: nil)
        params = {
            extended: extended ? '1' : '0',
            del: delete ? '1' : '0',
        }

        unless query.nil?
          params[:q] = query.to_s.encode('utf-8')
        end

        unless maxage.nil?
          params[:maxage] = maxage.to_i
        end

        unless offset.nil?
          params[:offset] = offset.to_i
        end

        unless limit.nil?
          params[:limit] = limit.to_i
        end

        unless group.empty?
          params[:group] = group.collect { |o| o.to_s.encode('utf-8') }.join(',')
        end

        unless cat.empty?
          params[:cat] = cat.collect { |o| o.to_s.encode('utf-8') }.join(',')
        end

        unless attrs.empty?
          params[:group] = attrs.collect { |o| o.to_s.encode('utf-8') }.join(',')
        end

        params
      end

    end
  end
end

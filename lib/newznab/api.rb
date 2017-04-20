require 'newznab/api/version'
require 'newznab/api/list'
require 'newznab/api/item'
require 'rest-client'
require 'cgi'
require 'json'
require 'mono_logger'
require 'open-uri'

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

##
# Base Newznab module
# @since 0.1.0
module Newznab

  ##
  # Class to interact and query the Newznab API
  # @since 0.1.0
  module Api
    API_FORMAT = 'json'
    API_FUNCTIONS = [:caps, :search, :tvsearch]

    ##
    # Raised when a function is not implemented on the current API
    #
    # Must be included in {Newznab::Api::API_FUNCTIONS}
    #
    # @since 0.1.0
    class FunctionNotSupportedError < ScriptError
    end

    ##
    # Raised when a Newznab API error is encountered
    #
    # @since 0.1.0
    class NewznabAPIError < ScriptError
    end


    class << self

      attr_accessor :api_uri, :api_key, :api_timeout, :api_rate_limit, :logger

      ##
      # @return [Newznab::API]
      # @param uri [String] Newznab API Uri
      # @param key [String] Newznab API Key
      # @since 0.1.0
      def new(uri: nil, key: nil)

        @api_rate_limit = 0

        @logger = MonoLogger.new(STDOUT)
        @logger.level = MonoLogger::WARN

        # Newznab API Key. Set to the environmental variable NEWZNAB_API_KEY by default if present
        @api_key = ENV['NEWZNAB_API_KEY'] || nil
        # Newznab API Uri. Set to the environmental variable NEWZNAB_URI by default if present
        @api_uri = ENV['NEWZNAB_URI'] || nil
        # Api response timeout in seconds
        @api_timeout = 10


        # Set passed uri
        unless uri.nil?
          @api_uri=uri
        end

        # Set passed key
        unless key.nil?
          @api_key=key
        end

        self
      end

      ##
      # Return the server's supported features and the protocol version and other metadata
      # Will perform a request to server if not set
      # @return [Hash]
      # @since 0.1.0
      # @macro raise.NewznabAPIError
      def caps
        @caps ||= _make_request(:caps)
      end

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
      # @param rageid [Integer] TVRage id of the item being queried.
      # @param season [String] Season string, e.g S13 or 13 for the item being queried.
      # @param ep [String] Episode string, e.g E13 or 13 for the item being queried.
      # @macro search.params
      # @macro raise.NewznabAPIError
      # @return [Newznab::SearchResults]
      # @since 0.1.0
      def tv_search(rageid: nil, season: nil, ep: nil, **params)
        args = _parse_search_args(**params)

        unless rageid.nil?
          args[:rageid] = URI::encode(rageid.to_s.encode('utf-8'))
        end

        unless season.nil?
          args[:season] = URI::encode(season.to_s.encode('utf-8'))
        end

        unless ep.nil?
          args[:ep] = URI::encode(ep.to_s.encode('utf-8'))
        end

        Newznab::Api::SearchResults.new(_make_request(:tvsearch, **args), :tvsearch, args)
      end

      ##
      # @param api_function [Symbol] Newznab function
      # @param params [Hash] The named key value pairs of query parameters
      # @macro raise.NewznabAPIError
      # @macro raise.FunctionNotSupportedError
      def get(api_function:, **params)
        _make_request(api_function, **params)
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

      ##
      # Will attempt to parse the {api_uri} and append '/api' to the end if needed
      # @since 0.1.0
      def _build_base_url
        if self.api_uri.to_s.match(/\/api$/)
          self.api_uri
        else
          self.api_uri + '/api'
        end
      end

      ##
      # Executes api request based on provided +function+ and +params+
      #
      # @example Return 5 results from the +:characters+ resource
      #   _make_request(:characters, limit: 5)
      #
      # @param function [Symbol] Newznab function
      # @param params [Hash] The named key value pairs of query parameters
      # @return [Hash]
      # @since 0.1.0
      # @macro raise.NewznabAPIError
      # @macro raise.FunctionNotSupportedError
      def _make_request(function, **params)

        unless API_FUNCTIONS.include?(function)
          logger.error("Function #{function.to_s} not supported")
          raise FunctionNotSupportedError, "Function #{function.to_s} not supported"
        end

        _make_url_request(_build_base_url, function, params)
      end

      ##
      # Executes api request based on provided +resource+ and +params+
      #
      # @example Make a simple request with +limit: 1+
      #   _make_url_request('http://newznabserver.com/api', t: :caps)
      #
      # @param url [String] Request url
      # @param function [Symbol] Newznab function
      # @param params [Hash] optional request parameters
      # @return [Hash]
      # @since 0.1.0
      # @macro raise.NewznabAPIError
      def _make_url_request(url, function, **params)

        # If we have a rate_limit set, wait that long before sending a request
        if api_rate_limit > 0
          sleep api_rate_limit
        end

        # Default options hash
        options = {
            accept: :json,
            content_type: :json,
            params: {
                apikey: self.api_key,
                o: Newznab::Api::API_FORMAT,
                t: function.to_s,
            }
        }

        options[:params].merge! params

        begin
          logger.debug("Request URL: #{url}")
          logger.debug("Request headers: #{options.to_json}")

          # Perform request
          request = RestClient::Request.execute(
              method: :get,
              url: url,
              timeout: self.api_timeout,
              headers: options,
          )

        rescue RestClient::NotFound, RestClient::Exceptions::ReadTimeout => e
          logger.error(e.message)
          raise NewznabAPIError, e.message
        end

        case request.code
          when 200
            req = JSON.parse(request.body)
            if req
              req
            else
              logger.error(req['error'])
              raise NewznabAPIError, req['error']
            end
          else
            logger.error('Recived a '+request.code+' http response')
            raise NewznabAPIError, 'Recived a '+request.code+' http response'
        end
      end

    end
  end
end

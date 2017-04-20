require 'newznab/api/version'
require 'newznab/api/list'
require 'newznab/api/item'
require 'newznab/api/search'
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

##
# Base Newznab module
module Newznab

  ##
  # Class to interact and query the Newznab API
  module Api
    # Response format from Newznab api
    # @since 0.1.0
    API_FORMAT = 'json'
    # Supported Newznab api functions
    # @since 0.1.0
    API_FUNCTIONS = [:caps, :search, :tvsearch, :movie, :music, :book]

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
      include Newznab::Api::Search

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
      # @param api_function [Symbol] Newznab function
      # @param params [Hash] The named key value pairs of query parameters
      # @macro raise.NewznabAPIError
      # @macro raise.FunctionNotSupportedError
      # @since 0.1.0
      def get(api_function:, **params)
        _make_request(api_function, **params)
      end

      private

      ##
      # Will attempt to parse the {api_uri} and append '/api' to the end if needed
      # @return [String]
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
      #   _make_request(:search, limit: 5)
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

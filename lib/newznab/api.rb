require 'newznab/api/version'
require 'rest-client'
require 'cgi'
require 'json'
require 'mono_logger'

## Yard Doc generation stuff
# @!macro [new] raise.FunctionNotSupportedError
#   @raise [FunctionNotSupportedError] indicating the resource requested is not supported
# @!macro [new] raise.NewznabAPIError
#   @raise [NewznabAPIError] indicating the api request code received

##
# Base Newznab module
# @since 0.1.0
module Newznab

  ##
  # Class to interact and query the Newznab API
  # @since 0.1.0
  module Api
    API_FORMAT = 'json'
    API_FUNCTIONS = [:caps, :search]

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

      attr_accessor :api_uri, :api_key, :api_timeout, :logger

      ##
      # @return [Newznab::API]
      # @param uri [String] Newznab API Uri
      # @param key [String] Newznab API Key
      # @since 0.1.0
      def new(uri: nil, key: nil)

        @logger = MonoLogger.new(STDOUT)
        @logger.level = MonoLogger::DEBUG

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
      # Query the server for supported features and the protocol version and other metadata
      # @return [Hash]
      # @since 0.1.0
      # @macro raise.NewznabAPIError
      def caps
        _make_request(:caps)
      end

      ##
      # @param function [Symbol] Newznab function
      # @param params [Hash] The named key value pairs of query parameters
      # @macro raise.NewznabAPIError
      # @macro raise.FunctionNotSupportedError
      def get(function, **params)
        _make_request(function, **params)
      end

      private

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

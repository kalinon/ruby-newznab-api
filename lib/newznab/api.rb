require 'newznab/api/version'

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

      ##
      # @return [Newznab::API]
      # @param uri [String] Newznab API Uri
      # @param key [String] Newznab API Key
      # @since 0.1.0
      def new(uri: nil, key: nil)

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
      # Returns Newznab API Key. Set to the environmental variable NEWZNAB_URI by default if present
      # @return [String]
      # @since 0.1.0
      def api_uri
        @api_uri || ENV['NEWZNAB_URI']
      end

      ##
      # Sets the Newznab API Uri. Overrides the environmental variable NEWZNAB_URI
      # @param uri [String]
      # @since 0.1.0
      def api_uri=(uri)
        @api_uri = uri
      end

      ##
      # Returns Newznab API Key. Set to the environmental variable NEWZNAB_API_KEY by default if present
      # @return [String]
      # @since 0.1.0
      def api_key
        @api_key || ENV['NEWZNAB_API_KEY']
      end

      ##
      # Sets the Newznab API Key. Overrides the environmental variable NEWZNAB_API_KEY
      # @param key [String]
      # @since 0.1.0
      def api_key=(key)
        @api_key = key
      end

      ##
      # Returns Newznab API request timeout value
      # @return [Integer]
      # @since 0.1.2
      def api_timeout
        @api_timeout
      end

      ##
      # Sets the Newznab API request timeout value in seconds
      # @param seconds [Integer]
      # @since 0.1.0
      def api_timeout=(seconds)
        @api_timeout = seconds.to_i
      end

    end
  end
end

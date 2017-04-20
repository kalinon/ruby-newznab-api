require 'newznab/api'

module Newznab

  ##
  # Enumerable list for multiple Newznab results
  # @since 0.1.0
  class List
    include Enumerable

    attr_reader :total_count
    attr_reader :offset
    attr_reader :limit
    attr_reader :cvos

    def initialize(resp, options)
      update_ivals(resp)

      if options.has_key? :limit
        @limit = options[:limit]
      end
    end

    def each
      @cvos.each { |c| yield c }
    end

    # Returns the current page the object is on
    # @return [Integer]
    def page
      (self.offset / self.limit) + 1
    end

    # Returns the total number of pages available
    # @return [Integer] Total number of pages
    # @since 0.1.0
    def total_pages
      (self.total_count / self.limit) + 1
    end

    # Returns if there are more pages to load
    # @return [true, false]
    # @since 0.1.0
    def has_more?
      self.total_pages > self.page ? true : false
    end

    protected

    ##
    # @param new_cvol [Hash] Response hash from {Newznab::Api}
    # @since 0.1.0
    def update_ivals(new_cvol)
      @_attributes = new_cvol['@attributes']

      if new_cvol.has_key?('channel') && new_cvol['channel'].has_key?('response')
        @total_count = new_cvol['channel']['response']['@attributes']['total'].to_i
        @offset = new_cvol['channel']['response']['@attributes']['offset'].to_i

        @cvos = new_cvol['channel']['item']
      end
    end

    def method_missing(id, *args)
      begin
        if @_attributes.has_key? id.to_s
          @_attributes[id.to_s]
        elsif @cvos.respond_to? id
          @cvos.method(id).call(*args)
        else
          super
        end
      end
    end

    def respond_to_missing?(id, *args)
      begin
        if @_attributes.has_key? id.to_s
          true
        elsif @cvos.respond_to? id
          true
        else
          super
        end
      end
    end
  end

  class SearchResults < List

    attr_reader :raw_resp, :query, :function

    # @param resp [Hash] Response hash from {Newznab::Api}
    # @param function [Symbol] Function from {Newznab::Api::API_FUNCTIONS}
    # @param query [Hash] Query parameters from search
    def initialize(resp, function, query)
      super(resp, query)

      @function = function
      @raw_resp = resp
      @query = query

      @cvos = resp['channel']['item'].collect { |o| Newznab::Item.new(o) }
    end

    # ##
    # Moves search to the next offset results
    def next_page!
      return nil if (self.offset + self.total_pages) >= self.total_count
      @query[:offset] = self.offset + self.limit
      self.update_ivals(Newznab::Api.get(api_function: self.function, **self.query))
    end

    ##
    # Moves search to the previous offset results
    def prev_page!
      return nil if @offset == 0
      @query[:offset] = self.offset - self.limit
      self.update_ivals(Newznab::Api.get(api_function: self.function, **self.query))
    end
  end

end

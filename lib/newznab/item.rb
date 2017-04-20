require 'newznab/api'

module Newznab
  class Item

    attr_reader :title, :guid, :link, :pub_date, :description, :metadata

    ##
    # @param args [Hash<String, Object>] Item hash from response
    # @return [Newznab::Item]
    def initialize(args)

      @raw_resp = args
      @metadata = {}

      args.each do |k, v|
        case k
          when 'title'
            @title = v
          when 'guid'
            @guid = v
          when 'link'
            @link = v
          when 'pubDate'
            @pub_date = Date.parse(v)
          when 'description'
            @description = v
          when 'enclosure'
            @_attributes = v['@attributes']
          when 'attr'
            @metadata = _parse_attr(v)
          else
            # Do nothing
        end
      end
    end

    private

    ##
    # @param attrs [Array<Hash<Hash<String, String>>>] Newznab attr array response
    # @return [Hash<String, Array<String>>]
    # @since 0.1.0
    def _parse_attr(attrs)

      metadata = {}
      attrs.each do |attr|
        name = attr['@attributes']['name']
        value = attr['@attributes']['value']

        if metadata.has_key? name
          metadata[name].push value
        else
          metadata[name] = [value]
        end

      end
      metadata
    end

    def method_missing(id, *args)
      begin
        if @_attributes.has_key? id.to_s
          @_attributes[id.to_s]
        elsif @metadata.has_key? id.to_s
          @metadata[id.to_s]
        else
          super
        end
      end
    end

    def respond_to_missing?(id, *args)
      begin
        if @_attributes.has_key? id.to_s
          true
        elsif @metadata.has_key? id.to_s
          true
        else
          super
        end
      end
    end
  end
end

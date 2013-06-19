module Lotus
  module Object
    require 'json'

    attr_reader :author
    attr_reader :content
    attr_reader :display_name
    attr_reader :uid
    attr_reader :url
    attr_reader :summary
    attr_reader :image

    attr_reader :published
    attr_reader :updated

    def initialize(options = {})
      @author       = options[:author]
      @content      = options[:content]
      @display_name = options[:display_name]
      @uid          = options[:uid]
      @url          = options[:url]
      @published    = options[:published]
      @updated      = options[:updated]
    end

    def to_hash
      {
        :author       => @author,
        :content      => @content,
        :display_name => @display_name,
        :uid          => @uid,
        :url          => @url,
        :published    => @published,
        :updated      => @updated,
      }
    end

    def to_json_hash
      {
        :author      => @author,
        :content     => @content,
        :displayName => @display_name,
        :id          => @uid,
        :url         => @url,
        :published   => @published.to_date.rfc3339 + 'Z',
        :updated     => @updated.to_date.rfc3339 + 'Z',
      }
    end

    # Returns a string containing the JSON representation of this Comment.
    def to_json(*args)
      to_json_hash.delete_if {|k,v| v.nil?}.to_json(args)
    end
  end
end

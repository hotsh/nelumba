module Lotus
  class Comment
    require 'json'

    attr_reader :author
    attr_reader :content
    attr_reader :display_name
    attr_reader :uid
    attr_reader :url
    attr_reader :published
    attr_reader :updated
    attr_reader :in_reply_to

    def initialize(options = {})
      @author       = options[:author]
      @content      = options[:content]
      @display_name = options[:display_name]
      @uid          = options[:uid]
      @url          = options[:url]
      @published    = options[:published]
      @updated      = options[:updated]
      @in_reply_to  = options[:in_reply_to] || []
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
        :in_reply_to  => @in_reply_to
      }
    end

    # Returns a string containing the JSON representation of this Comment.
    def to_json(*args)
      hash = to_hash.merge({:id => self.uid, :objectType => "comment"})
      hash.delete :uid
      hash[:published] = hash[:published].to_date.rfc3339 + 'Z'
      hash[:updated] = hash[:updated].to_date.rfc3339 + 'Z'
      hash[:displayName] = hash[:display_name]
      hash.delete :display_name
      hash.each {|k,v| hash.delete(k) if v.nil?}
      hash.to_json(args)
    end
  end
end

module Lotus
  class Comment
    attr_reader :author
    attr_reader :content
    attr_reader :display_name
    attr_reader :uid
    attr_reader :published
    attr_reader :updated
    attr_reader :in_reply_to

    def initialize(options = {})
      @author       = options[:author]
      @content      = options[:content]
      @display_name = options[:display_name]
      @uid          = options[:uid]
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
        :published    => @published,
        :updated      => @updated,
        :in_reply_to  => @in_reply_to
      }
    end
  end
end

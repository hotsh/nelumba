module Lotus
  module Object
    require 'json'

    # Determines what constitutes a username inside an update text
    USERNAME_REGULAR_EXPRESSION = /(^|[ \t\n\r\f"'\(\[{]+)@([^ \t\n\r\f&?=@%\/\#]*[^ \t\n\r\f&?=@%\/\#.!:;,"'\]}\)])(?:@([^ \t\n\r\f&?=@%\/\#]*[^ \t\n\r\f&?=@%\/\#.!:;,"'\]}\)]))?/

    attr_reader :title
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
      @summary      = options[:summary]
      @published    = options[:published] || Time.now
      @updated      = options[:updated] || Time.now
    end

    def to_hash
      {
        :author       => @author,
        :summary      => @summary,
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
        :summary     => @summary,
        :displayName => @display_name,
        :id          => @uid,
        :url         => @url,
        :published   => (@published ? @published.to_date.rfc3339 + 'Z' : nil),
        :updated     => (@updated ? @updated.to_date.rfc3339 + 'Z' : nil),
      }
    end

    # Returns a list of Lotus::Author's for those mentioned within the object.
    #
    # Requires a block that is given two arguments: the username and the domain
    # that should return a Lotus::Author that matches when a @username tag
    # is found.
    #
    # Usage:
    #
    # note = Lotus::Note.new(:text => "Hello @foo")
    # note.mentions do |username, domain|
    #   i = identities.select {|e| e.username == username && e.domain == domain }.first
    #   i.author if i
    # end
    #
    # With a persistence backend:
    # note.mentions do |username, domain|
    #   i = Identity.first(:username => /^#{Regexp.escape(username)}$/i)
    #   i.author if i
    # end
    def mentions(&blk)
      out = CGI.escapeHTML(self.content)

      # we let almost anything be in a username, except those that mess with urls.
      # but you can't end in a .:;, or !
      # also ignore container chars [] () "" '' {}
      # XXX: the _correct_ solution will be to use an email validator
      ret = []
      out.scan(USERNAME_REGULAR_EXPRESSION) do |beginning, username, domain|
        ret << blk.call(username, domain) if blk
      end

      ret
    end

    # Returns a string containing the JSON representation of this Comment.
    def to_json(*args)
      to_json_hash.delete_if {|k,v| v.nil?}.to_json(args)
    end
  end
end

module Nelumba
  module Object
    require 'json'

    # Determines what constitutes a username inside an update text
    USERNAME_REGULAR_EXPRESSION = /(^|[ \t\n\r\f"'\(\[{]+)@([^ \t\n\r\f&?=@%\/\#]*[^ \t\n\r\f&?=@%\/\#.!:;,"'\]}\)])(?:@([^ \t\n\r\f&?=@%\/\#]*[^ \t\n\r\f&?=@%\/\#.!:;,"'\]}\)]))?/

    attr_reader :title
    attr_reader :author
    attr_reader :display_name
    attr_reader :uid
    attr_reader :url

    # Natural-language description of this object
    attr_reader :summary

    # The image representation of this object
    attr_reader :image

    # Natural-language text content
    attr_reader :content

    attr_reader :published
    attr_reader :updated

    # Holds the content as plain text.
    attr_reader :text

    # Holds the content as html.
    attr_reader :html

    def initialize(options = {}, &blk)
      init(options, &blk)
    end

    def init(options = {}, &blk)
      @author       = options[:author]
      @content      = options[:content]
      @display_name = options[:display_name]
      @uid          = options[:uid]
      @url          = options[:url]
      @summary      = options[:summary]
      @published    = options[:published] || Time.now
      @updated      = options[:updated] || Time.now
      @title        = options[:title] || "Untitled"

      # Alternative representations of 'content'
      @text         = options[:text] || @content || ""
      @html         = options[:html] || to_html(&blk)

      @content      = @content || @html
    end

    # TODO: Convert html to safe text
    def to_text()
      return @text if @text

      return "" if @html.nil?

      ""
    end

    # Produces an HTML string representing the Object's content.
    #
    # Requires a block that is given two arguments: the username and the domain
    # that should return a Nelumba::Person that matches when a @username tag
    # is found.
    def to_html(&blk)
      return @html if @html

      return "" if @text.nil?

      out = CGI.escapeHTML(@text)

      # Replace any absolute addresses with a link
      # Note: Do this first! Otherwise it will add anchors inside anchors!
      out.gsub!(/(http[s]?:\/\/\S+[a-zA-Z0-9\/}])/, "<a href='\\1'>\\1</a>")

      # we let almost anything be in a username, except those that mess with urls.
      # but you can't end in a .:;, or !
      # also ignore container chars [] () "" '' {}
      # XXX: the _correct_ solution will be to use an email validator
      out.gsub!(USERNAME_REGULAR_EXPRESSION) do |match|
        if blk
          author = blk.call($2, $3)
        end

        if author
          "#{$1}<a href='#{author.uri}'>@#{$2}</a>"
        else
          "#{$1}<a href='#'>@#{$2}</a>"
        end
      end

      out.gsub!( /(^|\s+)#(\p{Word}+)/ ) do |match|
        "#{$1}<a href='/search?search=%23#{$2}'>##{$2}</a>"
      end

      out.gsub!(/\n/, "<br/>")

      out
    end

    # Returns a list of Nelumba::Person's for those replied by the object.
    #
    # Requires a block that is given two arguments: the username and the domain
    # that should return a Nelumba::Person that matches when a @username tag
    # is found.
    #
    # Usage:
    #
    # note = Nelumba::Note.new(:text => "Hello @foo")
    # note.reply_to do |username, domain|
    #   i = identities.select {|e| e.username == username && e.domain == domain }.first
    #   i.author if i
    # end
    #
    # With a persistence backend:
    # note.reply_to do |username, domain|
    #   i = Identity.first(:username => /^#{Regexp.escape(username)}$/i
    #   i.author if i
    # end
    def reply_to(&blk)
      out = CGI.escapeHTML(@text)

      # we let almost anything be in a username, except those that mess with urls.
      # but you can't end in a .:;, or !
      # also ignore container chars [] () "" '' {}
      # XXX: the _correct_ solution will be to use an email validator
      ret = []
      out.match(/^#{USERNAME_REGULAR_EXPRESSION}/) do |beginning, username, domain|
        ret << blk.call(username, domain) if blk
      end

      ret
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
        :title        => @title,
        :text         => @text,
        :html         => @html,
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
        :title       => @title,
        :published   => (@published ? @published.to_date.rfc3339 + 'Z' : nil),
        :updated     => (@updated ? @updated.to_date.rfc3339 + 'Z' : nil),
      }
    end

    # Returns a list of Nelumba::Person's for those mentioned within the object.
    #
    # Requires a block that is given two arguments: the username and the domain
    # that should return a Nelumba::Person that matches when a @username tag
    # is found.
    #
    # Usage:
    #
    # note = Nelumba::Note.new(:text => "Hello @foo")
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
      if self.respond_to? :text
        out = self.text || ""
      else
        out = self.content || ""
      end

      out = CGI.escapeHTML(out)

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

    # Returns a string containing the JSON representation of this Object.
    def to_json(*args)
      to_json_hash.delete_if{|k,v| v.nil?}.to_json(*args)
    end
  end
end

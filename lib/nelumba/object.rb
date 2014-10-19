# encoding: UTF-8

module Nelumba
  module Object
    require 'time-lord/units'
    require 'time-lord/scale'
    require 'time-lord/period'

    require 'json'
    require 'cgi'

    # Determines what constitutes a username inside an update text
    USERNAME_REGULAR_EXPRESSION = /(^|[ \t\n\r\f"'\(\[{]+)@([^ \t\n\r\f&?=@%\/\#]*[^ \t\n\r\f&?=@%\/\#.!:;,"'\]}\)])(?:@([^ \t\n\r\f&?=@%\/\#]*[^ \t\n\r\f&?=@%\/\#.!:;,"'\]}\)]))?/

    # The title of the object
    attr_reader :title

    # The content-type of the title
    attr_reader :title_type

    # The title with content type of text
    attr_reader :title_text

    # The title with content type of html
    attr_reader :title_html

    # Holds the list of authors as Nelumba::Person responsible for this feed.
    attr_reader :authors

    # Holds the source feed for this object
    attr_reader :source

    attr_reader :display_name
    attr_reader :uid
    attr_reader :url

    # The type of object
    attr_reader :type

    # Natural-language description of this object
    attr_reader :summary

    # The image representation of this object
    attr_reader :image

    # Natural-language text content
    attr_reader :content

    # The content type for the content
    attr_reader :content_type

    attr_reader :published
    attr_reader :updated

    # Holds the content as plain text.
    attr_reader :text

    # Holds the content as html.
    attr_reader :html

    # Holds a collection of Nelumba::Object's that this object is in reply to.
    attr_reader :in_reply_to

    # Holds an array of related Nelumba::Object's that are replies to this one.
    attr_reader :replies

    # Holds an array of Nelumba::Person's that have favorited this activity.
    attr_reader :likes

    # Holds an array of Nelumba::Person's that have shared this activity.
    attr_reader :shares

    # Holds an array of Nelumba::Person's that are mentioned in this activity.
    attr_reader :mentions

    # Holds a hash containing the information about interactions where keys
    # are verbs.
    #
    # For instance, it could have a :share key, with a hash containing the
    # number of times it has been shared.
    attr_reader :interactions

    def initialize(options = {}, &blk)
      init(options, &blk)
    end

    def init(options = {}, &blk)
      unless options[:in_reply_to].nil? or options[:in_reply_to].is_a?(Array)
        options[:in_reply_to] = [options[:in_reply_to]]
      end

      if options.has_key? :author
        if options[:author].is_a? Array
          options[:authors] = options[:author]
        else
          options[:authors] = [options[:author]]
        end
        options.delete :author
      end

      @authors       = options[:authors] || []
      @display_name  = options[:display_name]
      @uid           = options[:uid]
      @url           = options[:url]
      @summary       = options[:summary]
      @published     = options[:published]    || Time.now
      @updated       = options[:updated]      || Time.now
      @type          = options[:type]
      @in_reply_to   = options[:in_reply_to]  || []

      @replies       = options[:replies]      || []

      @mentions      = options[:mentions]     || []
      @likes         = options[:likes]        || []
      @shares        = options[:shares]       || []
      @source        = options[:source]

      @interactions  = options[:interactions] || {}

      options[:published] = @published
      options[:updated]   = @updated

      # Alternative representations of 'content'
      if options[:content]
        @content = options[:content]
        if options[:content_type]
          @content_type = options[:content_type]
        else
          @content_type = "text"
        end
      end

      @text          = options[:text] || @content || ""
      unless @content
        @content      = options[:text]
        @content_type = "text"
      end
      options[:text] = @text

      @html          = options[:html] || Nelumba::Object.to_html(@text, &blk)
      unless @content
        @content      = @html
        @content_type = "html"
      end
      options[:html] = @html

      # Alternative representations of 'title'
      if options[:title]
        @title = options[:title]
        if options[:title_type]
          @title_type = options[:title_type]
        else
          @title_type = "text"
        end
      end

      @title_text = options[:title_text] || @title || "Untitled"
      @title_html = options[:title_html] || Nelumba::Object.to_html(@title_text, &blk)

      if @title.nil?
        if @title_html
          @title      = @title_html
          @title_type = "html"
        elsif @title_text
          @title      = @title_text
          @title_type = "text"
        end
      end

      options[:title]        = @title
      options[:title_type]   = @title_type
      options[:title_text]   = @title_text
      options[:title_html]   = @title_html
      options[:content]      = @content
      options[:content_type] = @content_type
    end

    # TODO: Convert html to safe text
    def self.to_text(text)
      ""
    end

    # Produces an HTML string representing the Object's content.
    #
    # Requires a block that is given two arguments: the username and the domain
    # that should return a Nelumba::Person that matches when a @username tag
    # is found.
    def self.to_html(text, &blk)
      out = CGI.escapeHTML(text)

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
          "#{$1}<a href='#{author.url}'>@#{$2}</a>"
        else
          "#{$1}@#{$2}"
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

    def to_hash(scheme = 'https', domain = 'example.org', port = nil)
      url_start = "#{scheme}://#{domain}#{port.nil? ? "" : ":#{port}"}"

      uid = self.uid
      url = self.url

      if uid && uid.start_with?("/")
        uid = "#{url_start}#{uid}"
      end

      if url && url.start_with?("/")
        url = "#{url_start}#{url}"
      end

      {
        :source       => self.source,
        :authors      => self.authors.dup,
        :summary      => self.summary,
        :content      => self.content,
        :display_name => self.display_name,
        :uid          => uid,
        :url          => url,
        :published    => self.published,
        :updated      => self.updated,
        :title        => self.title,
        :title_text   => self.title_text,
        :title_html   => self.title_html,
        :object_type  => self.type,
        :text         => self.text,
        :html         => self.html,
        :in_reply_to  => (self.in_reply_to || []).dup,
        :replies      => self.replies.dup,
        :mentions     => self.mentions.dup,
        :likes        => self.likes.dup,
        :shares       => self.shares.dup,
      }
    end

    def to_json_hash(scheme = 'https', domain = 'example.org', port = nil)
      url_start = "#{scheme}://#{domain}#{port.nil? ? "" : ":#{port}"}"

      uid = self.uid
      url = self.url

      if uid && uid.start_with?("/")
        uid = "#{url_start}#{uid}"
      end

      if url && url.start_with?("/")
        url = "#{url_start}#{url}"
      end

      {
        :source      => self.source,
        :authors     => self.authors.dup,
        :content     => self.content,
        :summary     => self.summary,
        :displayName => self.display_name,
        :id          => uid,
        :url         => url,
        :title       => self.title,
        :objectType  => self.type,
        :published   => (self.published ? self.published.utc.iso8601 : nil),
        :updated     => (self.updated ? self.updated.utc.iso8601 : nil),
        :inReplyTo   => (self.in_reply_to || []).dup,
        :replies     => self.replies.dup,
        :mentions    => self.mentions.dup,
        :likes       => self.likes.dup,
        :shares      => self.shares.dup,
      }
    end

    # Returns the number of times the given verb has been used with this
    # Activity.
    def interaction_count(verb)
      hash = self.interactions
      if hash && hash.has_key?(verb)
        hash[verb][:count] || 0
      else
        0
      end
    end

    def published_ago_in_words
      TimeLord::Period.new(self.published.to_time, Time.now).to_words
    end

    def updated_ago_in_words
      TimeLord::Period.new(self.updated.to_time, Time.now).to_words
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
    def parse_mentions(&blk)
      out = self.text || ""

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

    def to_as1(*args)
      to_json_hash.delete_if{|k,v| v.nil?}.to_json(*args)
    end
  end
end

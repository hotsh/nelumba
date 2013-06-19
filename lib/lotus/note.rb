module Lotus
  class Note
    require 'json'

    # Determines what constitutes a username inside an update text
    USERNAME_REGULAR_EXPRESSION = /(^|[ \t\n\r\f"'\(\[{]+)@([^ \t\n\r\f&?=@%\/\#]*[^ \t\n\r\f&?=@%\/\#.!:;,"'\]}\)])(?:@([^ \t\n\r\f&?=@%\/\#]*[^ \t\n\r\f&?=@%\/\#.!:;,"'\]}\)]))?/

    # Holds the content as plain text.
    attr_reader :text

    # Holds the content as html.
    attr_reader :html

    # Holds a String containing the title of the note.
    attr_reader :title

    # The person responsible for writing this note.
    attr_reader :author

    # Unique id that identifies this note.
    attr_reader :uid

    # The date the note originally was published.
    attr_reader :published

    # The date the note was last updated.
    attr_reader :updated

    # The permanent location for an html representation of the note.
    attr_reader :url

    # Create a new note.
    #
    # options:
    #   :title        => The title of the note. Defaults: "Untitled"
    #   :text         => The content of the note. Defaults: ""
    #   :html         => The content of the note as html.
    #   :author       => An Author that wrote the note.
    #   :url          => Permanent location for an html representation of the
    #                    note.
    #   :published    => When the note was originally published.
    #   :updated      => When the note was last updated.
    #   :uid          => The unique id that identifies this note.
    def initialize(options = {}, &blk)
      @text      = options[:text] || ""
      @html      = options[:html] || to_html(&blk)
      @title     = options[:title] || "Untitled"
      @author    = options[:author]
      @url       = options[:url]
      @published = options[:published]
      @updated   = options[:updated]
      @uid       = options[:uid]
    end

    # Produces an HTML string representing the note's content.
    #
    # Requires a block that is given two arguments: the username and the domain
    # that should return a Lotus::Author that matches when a @username tag
    # is found.
    def to_html(&blk)
      return @html if @html

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

      out
    end

    # Returns a list of Lotus::Author's for those mentioned within the note.
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
    #   i = Identity.first(:username => /^#{Regexp.escape(username)}$/i
    #   i.author if i
    # end
    def mentions(&blk)
      out = CGI.escapeHTML(@text)

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

    # Returns a list of Lotus::Author's for those replied by the note.
    #
    # Requires a block that is given two arguments: the username and the domain
    # that should return a Lotus::Author that matches when a @username tag
    # is found.
    #
    # Usage:
    #
    # note = Lotus::Note.new(:text => "Hello @foo")
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
        :text      => @text,
        :html      => @html,
        :title     => @title,
        :author    => @author,
        :url       => @url,
        :published => @published,
        :updated   => @updated,
        :uid       => @uid
      }
    end

    # Returns a string containing the JSON representation of this Note.
    def to_json(*args)
      hash = to_hash.merge({:id => self.uid, :objectType => "note", :content => self.html})
      hash.delete(:text)
      hash.delete(:html)
      hash.delete(:uid)
      hash[:published] = hash[:published].to_date.rfc3339 + 'Z'
      hash[:updated] = hash[:updated].to_date.rfc3339 + 'Z'
      hash.each {|k,v| hash.delete(k) if v.nil?}
      hash.to_json(args)
    end
  end
end

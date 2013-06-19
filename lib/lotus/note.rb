module Lotus
  class Note
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
    def initialize(options = {})
      @text      = options[:text] || ""
      @html      = options[:html]
      @title     = options[:title] || "Untitled"
      @author    = options[:author]
      @url       = options[:url]
      @published = options[:published]
      @updated   = options[:updated]
      @uid       = options[:uid]
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
  end
end

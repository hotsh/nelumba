module Lotus
  class Note
    # Holds the content.
    attr_reader :content

    # Holds the MIME type of the content.
    attr_reader :content_type

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
    #   :content      => The content of the note. Defaults: ""
    #   :content_type => The MIME type of the note. Defaults: "text/plain"
    #   :author       => An Author that wrote the note.
    #   :url          => Permanent location for an html representation of the
    #                    note.
    #   :published    => When the note was originally published.
    #   :updated      => When the note was last updated.
    #   :uid          => The unique id that identifies this note.
    def initialize(options = {})
      @content      = options[:content] || ""
      @content_type = options[:content_type] || "text/plain"
      @title        = options[:title] || "Untitled"
      @author       = options[:author]
      @url          = options[:url]
      @published    = options[:published]
      @updated      = options[:updated]
      @uid          = options[:uid]
    end

    def to_hash
      {
        :content      => @content,
        :content_type => @content_type,
        :title        => @title,
        :author       => @author,
        :url          => @url,
        :published    => @published,
        :updated      => @updated,
        :uid          => @uid
      }
    end
  end
end

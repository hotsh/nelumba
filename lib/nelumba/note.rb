module Nelumba
  class Note
    include Nelumba::Object

    # Create a new note.
    #
    # options:
    #   :title        => The title of the note. Defaults: "Untitled"
    #   :text         => The content of the note. Defaults: ""
    #   :html         => The content of the note as html.
    #   :author       => An Person that wrote the note.
    #   :url          => Permanent location for an html representation of the
    #                    note.
    #   :published    => When the note was originally published.
    #   :updated      => When the note was last updated.
    #   :uid          => The unique id that identifies this note.
    def initialize(options = {}, &blk)
      init(options, &blk)
    end

    def init(options = {}, &blk)
      options ||= {}
      options[:type] = :note

      super(options, &blk)
    end

    # Returns a hash of all relevant fields.
    def to_hash
      super.to_hash
    end
  end
end

module Lotus
  # This class represents an Activity object for an Lotus::Entry.
  class Activity
    require 'time-lord/units'
    require 'time-lord/scale'
    require 'time-lord/period'

    # The object of this activity.
    attr_reader :object

    # The type of object for this activity.
    #
    # The field can be a String for uncommon types. Several are standard:
    #   :article, :audio, :bookmark, :comment, :file, :folder, :group,
    #   :list, :note, :person, :photo, :"photo-album", :place, :playlist,
    #   :product, :review, :service, :status, :video
    attr_reader :type

    # The action being invoked in this activity.
    #
    # The field can be a String for uncommon verbs. Several are standard:
    #   :favorite, :follow, :like, :"make-friend", :join, :play,
    #   :post, :save, :share, :tag, :update
    attr_reader :verb

    # The target of the action.
    attr_reader :target

    # Holds a String containing the title of the entry.
    attr_reader :title

    # Holds an Lotus::Author.
    attr_reader :actor

    # Holds the content.
    attr_reader :content

    # Holds the MIME type of the content.
    attr_reader :content_type

    # Holds the id that uniquely identifies this entry.
    attr_reader :uid

    # Holds the url that represents the entry.
    attr_reader :url

    # Holds the source of this entry as an Lotus::Feed.
    attr_reader :source

    # Holds the DateTime of when the entry was published originally.
    attr_reader :published

    # Holds the DateTime of when the entry was last modified.
    attr_reader :updated

    # Holds an array of related Lotus::Activity's that this entry is a response
    # to.
    attr_reader :in_reply_to

    # Holds an array of related Lotus::Activity's that are replies to this one.
    attr_reader :replies

    # Holds an array of Lotus::Author's that have favorited this activity.
    attr_reader :likes

    # Holds an array of Lotus::Author's that have shared this activity.
    attr_reader :shares

    # Holds an array of Lotus::Author's that are mentioned in this activity.
    attr_reader :mentions

    # Create a new entry with the given content.
    #
    # options:
    #   :object      => The object of this activity.
    #   :type        => The type of object for this activity.
    #   :target      => The target of this activity.
    #   :verb        => The action of the activity.
    #
    #   :title        => The title of the entry. Defaults: "Untitled"
    #   :actor        => An Lotus::Author responsible for generating this entry.
    #   :content      => The content of the entry. Defaults: ""
    #   :content_type => The MIME type of the content.
    #   :source       => An Lotus::Feed where this Entry originated. This
    #                    should be used when an Entry is copied into this feed
    #                    from another.
    #   :published    => The DateTime depicting when the entry was originally
    #                    published.
    #   :updated      => The DateTime depicting when the entry was modified.
    #   :url          => The canonical url of the entry.
    #   :uid          => The unique id that identifies this entry.
    #   :activity     => The activity this entry represents. Either a single string
    #                    denoting what type of object this entry represents, or an
    #                    entire Lotus::Activity when a more detailed description is
    #                    appropriate.
    #   :in_reply_to  => An Lotus::Entry for which this entry is a response.
    #                    Or an array of Lotus::Entry's that this entry is a
    #                    response to. Use this when this Entry is a reply
    #                    to an existing Entry.
    def initialize(options = {})
      @object      = options[:object]
      @type        = options[:type]
      @target      = options[:target]
      @verb        = options[:verb]

      @title        = options[:title] || "Untitled"
      @actor        = options[:actor]
      @content      = options[:content] || ""
      @content_type = options[:content_type]
      @source       = options[:source]
      @published    = options[:published]
      @updated      = options[:updated]
      @url          = options[:url]
      @uid          = options[:uid]

      unless options[:in_reply_to].nil? or options[:in_reply_to].is_a?(Array)
        options[:in_reply_to] = [options[:in_reply_to]]
      end

      @in_reply_to  = options[:in_reply_to] || []
      @replies      = options[:replies]     || []

      @mentions     = options[:mentions]    || []
      @likes        = options[:likes]       || []
      @shares       = options[:shares]      || []
    end

    def published_ago_in_words
      TimeLord::Period.new(self.published.to_time, Time.now).to_words
    end

    def updated_ago_in_words
      TimeLord::Period.new(self.updated.to_time, Time.now).to_words
    end

    # Returns a hash of all relevant fields.
    def to_hash
      {
        :source => self.source,
        :title => self.title,
        :content => self.content,
        :content_type => self.content_type,
        :published => self.published,
        :updated => self.updated,
        :url => self.url,
        :uid => self.uid,

        :in_reply_to => self.in_reply_to.dup,
        :replies => self.replies.dup,

        :mentions => self.mentions.dup,
        :likes => self.likes.dup,
        :shares => self.shares.dup,

        :object => self.object,
        :target => self.target,
        :actor => self.actor,
        :verb => self.verb,
        :type => self.type
      }
    end

    # Returns a string containing the Atom representation of this Activity.
    def to_atom
      require 'lotus/atom/entry'

      Lotus::Atom::Entry.from_canonical(self).to_xml
    end
  end
end

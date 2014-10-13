module Nelumba
  # This class represents a Nelumba::Feed object.
  class Feed < Nelumba::Collection
    require 'open-uri'
    require 'date'

    # Holds the list of categories for this feed as Nelumba::Category.
    attr_reader :categories

    # Holds human-readable information about the content rights of the entries
    # in the feed without an explicit rights field of their own. SHOULD NOT be
    # machine interpreted.
    attr_reader :rights

    # The subtitle of the feed
    attr_reader :subtitle

    # The content-type of the subtitle of the feed
    attr_reader :subtitle_type

    # The subtitle with content type of text
    attr_reader :subtitle_text

    # The subtitle with content type of html
    attr_reader :subtitle_html

    # Holds the URL for the icon representing this feed.
    attr_reader :icon

    # Holds the URL for the logo representing this feed.
    attr_reader :logo

    # Holds the generator for this content as an Nelumba::Generator.
    attr_reader :generator

    # Holds the list of contributors, if any, that are involved in this feed
    # as Nelumba::Person.
    attr_reader :contributors

    # Holds the list of hubs that are available to manage subscriptions to this
    # feed.
    attr_reader :hubs

    # Holds the salmon url that handles notifications for this feed.
    attr_reader :salmon_url

    # Holds links to other resources as an array of Nelumba::Link
    attr_reader :links

    # Creates a new representation of a feed.
    #
    # options:
    #   uid           => The unique identifier for this feed.
    #   url           => The url that represents this feed.
    #   title         => The title for this feed. Defaults: "Untitled"
    #   subtitle      => The subtitle for this feed.
    #   authors       => The list of Nelumba::Person's for this feed.
    #                    Defaults: []
    #   contributors  => The list of Nelumba::Person's that contributed to this
    #                    feed. Defaults: []
    #   items         => The list of Nelumba::Activity's for this feed.
    #                    Defaults: []
    #   icon          => The url of the icon that represents this feed. It
    #                    should have an aspect ratio of 1 horizontal to 1
    #                    vertical and optimized for presentation at a
    #                    small size.
    #   logo          => The url of the logo that represents this feed. It
    #                    should have an aspect ratio of 2 horizontal to 1
    #                    vertical.
    #   categories    => An array of Nelumba::Category's that describe how to
    #                    categorize and describe the content of the feed.
    #                    Defaults: []
    #   rights        => A String depicting the rights of items without
    #                    explicit rights of their own. SHOULD NOT be machine
    #                    interpreted.
    #   updated       => The DateTime representing when this feed was last
    #                    modified.
    #   published     => The DateTime representing when this feed was originally
    #                    published.
    #   salmon_url    => The url of the salmon endpoint, if one exists, for this
    #                    feed.
    #   links         => An array of Nelumba::Link that adds relations to other
    #                    resources.
    #   generator     => A Nelumba::Generator representing the agent
    #                    responsible for generating this feed.
    #
    # Usage:
    #
    #   author = Nelumba::Person.new(:name => "Kelly")
    #
    #   feed = Nelumba::Feed.new(:title     => "My Feed",
    #                            :uid     => "1",
    #                            :url     => "http://example.com/feeds/1",
    #                            :authors => [author])
    def initialize(options = {}, &blk)
      init(options, &blk)
    end

    def init(options = {}, &blk)
      super options, &blk

      @icon         = options[:icon]
      @subtitle     = options[:subtitle]
      @logo         = options[:logo]
      @rights       = options[:rights]
      @authors      = options[:authors] || []
      @categories   = options[:categories] || []
      @contributors = options[:contributors] || []
      @salmon_url   = options[:salmon_url]
      @hubs         = options[:hubs] || []
      @generator    = options[:generator]

      # Alternative representations of 'subtitle'
      if options[:subtitle]
        @subtitle = options[:subtitle]
        if options[:subtitle_type]
          @subtitle_type = options[:subtitle_type]
        else
          @subtitle_type = "text"
        end
      end

      @subtitle_text = options[:subtitle_text] || @subtitle || ""
      @subtitle_html = options[:subtitle_html] || Nelumba::Object.to_html(@subtitle_text, &blk)

      if @subtitle.nil?
        if @subtitle_html
          @subtitle      = @subtitle_html
          @subtitle_type = "html"
        elsif @subtitle_text
          @subtitle      = @subtitle_text
          @subtitle_type = "text"
        end
      end

      options[:subtitle]        = @subtitle
      options[:subtitle_type]   = @subtitle_type
      options[:subtitle_text]   = @subtitle_text
      options[:subtitle_html]   = @subtitle_html
    end

    # Yields a Nelumba::Link to this feed.
    #
    # options: Can override Nelumba::Link properties, such as rel.
    #
    # Usage:
    #
    #   feed = Nelumba::Feed.new(:title => "Foo", :url => "http://example.com")
    #   feed.to_link(:rel => "alternate", :title => "Foo's Feed")
    #
    # Generates a link with:
    #   <Nelumba::Link rel="alternate" title="Foo's Feed" url="http://example.com">
    def to_link(options = {})
      options = { :title => self.title,
                  :href  => self.url }.merge(options)

      Nelumba::Link.new(options)
    end

    # Returns a hash of the properties of the feed.
    def to_hash
      {
        :hubs => (self.hubs || []).dup,
        :icon => self.icon,
        :logo => self.logo,
        :rights => self.rights,
        :subtitle => self.subtitle,
        :subtitle_text => self.subtitle_text,
        :subtitle_html => self.subtitle_html,
        :authors => (self.authors || []).dup,
        :categories => (self.categories || []).dup,
        :contributors => (self.contributors || []).dup,
        :updated => self.updated,
        :salmon_url => self.salmon_url,
        :published => self.published,
        :generator => self.generator
      }.merge(super)
    end

    def to_json_hash
      {
      }.merge(super)
    end

    # Returns a string containing an Atom representation of the feed.
    def to_atom
      require 'nelumba/atom/feed'

      Nelumba::Atom::Feed.from_canonical(self)
    end
  end
end

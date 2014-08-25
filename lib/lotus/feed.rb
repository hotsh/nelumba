module Lotus
  # This class represents a Lotus::Feed object.
  class Feed < Lotus::Collection
    require 'open-uri'
    require 'date'

    # Holds the list of categories for this feed as Lotus::Category.
    attr_reader :categories

    # Holds human-readable information about the content rights of the entries
    # in the feed without an explicit rights field of their own. SHOULD NOT be
    # machine interpreted.
    attr_reader :rights

    # Holds the title for this feed.
    attr_reader :title

    # Holds the content-type for the title.
    attr_reader :title_type

    # Holds the subtitle for this feed.
    attr_reader :subtitle

    # Holds the content-type for the subtitle.
    attr_reader :subtitle_type

    # Holds the URL for the icon representing this feed.
    attr_reader :icon

    # Holds the URL for the logo representing this feed.
    attr_reader :logo

    # Holds the generator for this content as an Lotus::Generator.
    attr_reader :generator

    # Holds the list of contributors, if any, that are involved in this feed
    # as Lotus::Person.
    attr_reader :contributors

    # Holds the list of authors as Lotus::Person responsible for this feed.
    attr_reader :authors

    # Holds the list of hubs that are available to manage subscriptions to this
    # feed.
    attr_reader :hubs

    # Holds the salmon url that handles notifications for this feed.
    attr_reader :salmon_url

    # Holds links to other resources as an array of Lotus::Link
    attr_reader :links

    # Creates a new representation of a feed.
    #
    # options:
    #   uid           => The unique identifier for this feed.
    #   url           => The url that represents this feed.
    #   title         => The title for this feed. Defaults: "Untitled"
    #   title_type    => The content type for the title.
    #   subtitle      => The subtitle for this feed.
    #   subtitle_type => The content type for the subtitle.
    #   authors       => The list of Lotus::Person's for this feed.
    #                    Defaults: []
    #   contributors  => The list of Lotus::Person's that contributed to this
    #                    feed. Defaults: []
    #   items         => The list of Lotus::Activity's for this feed.
    #                    Defaults: []
    #   icon          => The url of the icon that represents this feed. It
    #                    should have an aspect ratio of 1 horizontal to 1
    #                    vertical and optimized for presentation at a
    #                    small size.
    #   logo          => The url of the logo that represents this feed. It
    #                    should have an aspect ratio of 2 horizontal to 1
    #                    vertical.
    #   categories    => An array of Lotus::Category's that describe how to
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
    #   links         => An array of Lotus::Link that adds relations to other
    #                    resources.
    #   generator     => A Lotus::Generator representing the agent
    #                    responsible for generating this feed.
    #
    # Usage:
    #
    #   author = Lotus::Person.new(:name => "Kelly")
    #
    #   feed = Lotus::Feed.new(:title     => "My Feed",
    #                            :uid     => "1",
    #                            :url     => "http://example.com/feeds/1",
    #                            :authors => [author])
    def initialize(options = {}, &blk)
      init(options, &blk)
    end

    def init(options = {})
      super options

      @icon = options[:icon]
      @logo = options[:logo]
      @rights = options[:rights]
      @title = options[:title] || "Untitled"
      @title_type = options[:title_type]
      @subtitle = options[:subtitle]
      @subtitle_type = options[:subtitle_type]
      @authors = options[:authors] || []
      @categories = options[:categories] || []
      @contributors = options[:contributors] || []
      @salmon_url = options[:salmon_url]
      @hubs = options[:hubs] || []
      @generator = options[:generator]
    end

    # Yields a Lotus::Link to this feed.
    #
    # options: Can override Lotus::Link properties, such as rel.
    #
    # Usage:
    #
    #   feed = Lotus::Feed.new(:title => "Foo", :url => "http://example.com")
    #   feed.to_link(:rel => "alternate", :title => "Foo's Feed")
    #
    # Generates a link with:
    #   <Lotus::Link rel="alternate" title="Foo's Feed" url="http://example.com">
    def to_link(options = {})
      options = { :title => self.title,
                  :href  => self.url }.merge(options)

      Lotus::Link.new(options)
    end

    # Returns a hash of the properties of the feed.
    def to_hash
      {
        :hubs => (self.hubs || []).dup,
        :icon => self.icon,
        :logo => self.logo,
        :rights => self.rights,
        :title => self.title,
        :title_type => self.title_type,
        :subtitle => self.subtitle,
        :subtitle_type => self.subtitle_type,
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
      require 'lotus/atom/feed'

      Lotus::Atom::Feed.from_canonical(self).to_xml
    end
  end
end

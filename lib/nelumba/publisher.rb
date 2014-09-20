module Nelumba
  class Publisher
    require 'net/http'
    require 'uri'

    # The url of the feed.
    attr_reader :url

    # The array of feed urls used to push content. Default: []
    attr_reader :hubs

    # Creates a representation of a Publisher entity.
    #
    # options:
    #   :feed => A feed to use to populate the other fields.
    #   :url  => The url of the feed that will be published.
    #   :hubs => An array of hub urls that are used to handle load
    #            balancing pushes of new data. Default: []
    def initialize(options = {}, &blk)
      init(options, &blk)
    end

    def init(options = {}, &blk)
      if options[:feed]
        @url  = options[:feed].url
        @hubs = options[:feed].hubs
      end

      @url  ||= options[:url]
      @hubs ||= options[:hubs] || []
    end

    # Will ping PuSH hubs so that they know there is new/updated content. The
    # hub should respond by pulling the new data and then sending it to
    # subscribers.
    def ping_hubs
      @hubs.each do |hub_url|
        res = Net::HTTP.post_form(URI.parse(hub_url),
                                  { 'hub.mode' => 'publish',
                                    'hub.url' => @topic_url })
      end
    end
  end
end

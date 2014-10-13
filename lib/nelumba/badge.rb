module Nelumba
  class Badge
    include Nelumba::Object

    # Create a new badge.
    #
    # options:
    #   :title        => The title of the badge. Defaults: "Untitled"
    #   :text         => The content of the badge. Defaults: ""
    #   :html         => The content of the badge as html.
    #   :author       => An Person that wrote the badge.
    #   :url          => Permanent location for an html representation of the
    #                    badge.
    #   :published    => When the badge was originally published.
    #   :updated      => When the badge was last updated.
    #   :uid          => The unique id that identifies this badge.
    def initialize(options = {}, &blk)
      options ||= {}
      options[:type] = :badge
      init(options, &blk)
    end
  end
end

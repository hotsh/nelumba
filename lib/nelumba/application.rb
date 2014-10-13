module Nelumba
  class Application
    include Nelumba::Object

    # Create a new application.
    #
    # options:
    #   :title        => The title of the application. Defaults: "Untitled"
    #   :text         => The content of the application. Defaults: ""
    #   :html         => The content of the application as html.
    #   :author       => An Person that wrote the application.
    #   :url          => Permanent location for an html representation of the
    #                    application.
    #   :published    => When the application was originally published.
    #   :updated      => When the application was last updated.
    #   :uid          => The unique id that identifies this application.
    def initialize(options = {}, &blk)
      options ||= {}
      options[:type] = :application
      init(options, &blk)
    end

    def init(options = {}, &blk)
      options ||= {}
      options[:type] = "application"

      super options, &blk
    end
  end
end

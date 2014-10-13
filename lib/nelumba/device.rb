module Nelumba
  class Device
    include Nelumba::Object

    # Create a new device.
    #
    # options:
    #   :title        => The title of the device. Defaults: "Untitled"
    #   :text         => The content of the device. Defaults: ""
    #   :html         => The content of the device as html.
    #   :author       => An Person that wrote the device.
    #   :url          => Permanent location for an html representation of the
    #                    device.
    #   :published    => When the device was originally published.
    #   :updated      => When the device was last updated.
    #   :uid          => The unique id that identifies this device.
    def initialize(options = {}, &blk)
      options ||= {}
      options[:type] = :device
      init(options, &blk)
    end
  end
end

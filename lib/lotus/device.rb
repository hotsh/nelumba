module Lotus
  class Device
    include Lotus::Object

    def to_json_hash
      {
        :objectType => "device"
      }.merge(super)
    end
  end
end

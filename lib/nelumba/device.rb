module Nelumba
  class Device
    include Nelumba::Object

    def to_json_hash
      {
        :objectType => "device"
      }.merge(super)
    end
  end
end

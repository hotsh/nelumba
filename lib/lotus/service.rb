module Lotus
  class Service
    include Lotus::Object

    def to_json_hash
      {
        :objectType => "service"
      }.merge(super)
    end
  end
end

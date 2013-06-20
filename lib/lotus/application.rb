module Lotus
  class Application
    include Lotus::Object

    def to_json_hash
      {
        :objectType => "application"
      }.merge(super)
    end
  end
end

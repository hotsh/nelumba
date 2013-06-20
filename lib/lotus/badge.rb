module Lotus
  class Badge
    include Lotus::Object

    def to_json_hash
      {
        :objectType => "badge"
      }.merge(super)
    end
  end
end

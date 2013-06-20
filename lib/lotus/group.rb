module Lotus
  class Group
    include Lotus::Object

    def to_json_hash
      {
        :objectType => "group"
      }.merge(super)
    end
  end
end

module Nelumba
  class Group
    include Nelumba::Object

    def to_json_hash
      {
        :objectType => "group"
      }.merge(super)
    end
  end
end

module Nelumba
  class Badge
    include Nelumba::Object

    def to_json_hash
      {
        :objectType => "badge"
      }.merge(super)
    end
  end
end

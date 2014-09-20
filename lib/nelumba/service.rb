module Nelumba
  class Service
    include Nelumba::Object

    def to_json_hash
      {
        :objectType => "service"
      }.merge(super)
    end
  end
end

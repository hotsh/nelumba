module Nelumba
  class Application
    include Nelumba::Object

    def to_json_hash
      {
        :objectType => "application"
      }.merge(super)
    end
  end
end

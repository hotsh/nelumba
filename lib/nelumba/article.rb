module Nelumba
  class Article
    include Nelumba::Object

    def to_json_hash
      {
        :objectType => "article"
      }.merge(super)
    end
  end
end

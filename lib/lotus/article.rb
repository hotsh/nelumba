module Lotus
  class Article
    include Lotus::Object

    def to_json_hash
      {
        :objectType => "article"
      }.merge(super)
    end
  end
end

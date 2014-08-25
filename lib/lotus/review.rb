module Lotus
  class Review
    include Lotus::Object

    attr_reader :rating

    def initialize(options = {}, &blk)
      init(options, &blk)
    end

    def init(options = {}, &blk)
      super options

      @rating = options[:rating]
    end

    def to_hash
      {
        :rating => @rating
      }.merge(super)
    end

    def to_json_hash
      {
        :objectType => "review",
        :rating     => @rating
      }.merge(super)
    end
  end
end

module Nelumba
  class Review
    include Nelumba::Object

    attr_reader :rating

    def initialize(options = {}, &blk)
      init(options, &blk)
    end

    def init(options = {}, &blk)
      options ||= {}
      options[:type] = :review

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
        :rating     => @rating
      }.merge(super)
    end
  end
end

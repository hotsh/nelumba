module Nelumba
  class Image
    include Nelumba::Object

    attr_reader :full_image

    def initialize(options = {}, &blk)
      init(options, &blk)
    end

    def init(options = {}, &blk)
      options ||= {}
      options[:type] = :image

      super(options, &blk)

      @full_image = options[:full_image]
    end

    def to_hash
      {
        :full_image => @full_image
      }.merge(super)
    end

    def to_json_hash
      {
        :fullImage  => @full_image
      }.merge(super)
    end
  end
end

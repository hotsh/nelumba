module Nelumba
  class Place
    include Nelumba::Object

    attr_reader :position
    attr_reader :address

    def initialize(options = {}, &blk)
      init(options, &blk)
    end

    def init(options = {}, &blk)
      super(options, &blk)

      @position = options[:position]
      @address  = options[:address]
    end

    def to_hash
      {
        :position => @position,
        :address  => @address
      }.merge(super)
    end

    def to_json_hash
      {
        :objectType => "place",
        :position   => @position,
        :address    => @address
      }.merge(super)
    end
  end
end

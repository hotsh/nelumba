module Lotus
  class Place
    include Lotus::Object

    attr_reader :position
    attr_reader :address

    def initialize(options = {})
      super options

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

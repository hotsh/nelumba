module Lotus
  class Collection
    include Lotus::Object

    attr_reader :items
    attr_reader :total_items

    def initialize(options = {})
      super options

      @items       = options[:items] || []
      @total_items = options[:total_items] || @items.count
    end

    def to_hash
      {
        :items       => (@items || []).dup,
        :total_items => @total_items
      }.merge(super)
    end

    def to_json_hash
      {
        :objectType => "collection",
        :items      => (@items || []).dup,
        :totalItems => @total_items
      }.merge(super)
    end
  end
end

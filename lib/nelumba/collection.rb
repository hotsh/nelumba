module Nelumba
  class Collection
    include Nelumba::Object

    attr_reader :items
    attr_reader :total_items

    def initialize(options = {}, &blk)
      init(options, &blk)
    end

    def init(options = {}, &blk)
      options ||= {}
      options[:type] = :collection

      super(options, &blk)

      @items       = options[:items] || []
      @total_items = options[:total_items] || @items.count
    end

    def to_hash
      {
        :items       => (self.items || []).dup,
        :total_items => self.total_items || self.items.count
      }.merge(super)
    end

    def to_json_hash
      {
        :items      => (self.items || []).dup,
        :totalItems => self.total_items || self.items.count
      }.merge(super)
    end
  end
end

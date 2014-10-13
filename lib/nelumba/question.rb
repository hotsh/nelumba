module Nelumba
  class Question
    include Nelumba::Object

    attr_reader :options

    def initialize(options = {}, &blk)
      init(options, &blk)
    end

    def init(options = {}, &blk)
      options ||= {}
      options[:type] = :question

      super(options, &blk)

      @options = options[:options] || []
    end

    def to_hash
      {
        :options => @options.dup
      }.merge(super)
    end

    def to_json_hash
      {
        :options    => @options.dup
      }.merge(super)
    end
  end
end

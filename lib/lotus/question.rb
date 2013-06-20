module Lotus
  class Question
    include Lotus::Object

    attr_reader :options

    def initialize(options = {})
      super options

      @options = options[:options] || []
    end

    def to_hash
      {
        :options => @options.dup
      }.merge(super)
    end

    def to_json_hash
      {
        :objectType => "question",
        :options    => @options.dup
      }.merge(super)
    end
  end
end

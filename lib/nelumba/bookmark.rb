module Nelumba
  class Bookmark
    include Nelumba::Object

    attr_reader :target_url

    def initialize(options = {}, &blk)
      init(options, &blk)
    end

    def init(options = {}, &blk)
      options ||= {}
      options[:type] = :bookmark

      super(options, &blk)

      @target_url = options[:target_url]
    end

    def to_hash
      {
        :target_url => @target_url
      }.merge(super)
    end

    def to_json_hash
      {
        :targetUrl  => @target_url
      }.merge(super)
    end
  end
end

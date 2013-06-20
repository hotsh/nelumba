module Lotus
  class Bookmark
    include Lotus::Object

    attr_reader :target_url

    def initialize(options = {})
      super options

      @target_url = options[:target_url]
    end

    def to_hash
      {
        :target_url => @target_url
      }.merge(super)
    end

    def to_json_hash
      {
        :objectType => "bookmark",
        :targetUrl  => @target_url
      }.merge(super)
    end
  end
end

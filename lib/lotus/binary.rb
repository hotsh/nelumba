module Lotus
  class Binary
    include Lotus::Object

    attr_reader :data
    attr_reader :length

    attr_reader :md5
    attr_reader :compression

    attr_reader :file_url
    attr_reader :mime_type

    def initialize(options = {}, &blk)
      init(options, &blk)
    end

    def init(options = {}, &blk)
      super(options, &blk)

      @data        = options[:data]
      @compression = options[:compression]
      @md5         = options[:md5]
      @file_url    = options[:file_url]
      @mime_type   = options[:mime_type]
      @length      = options[:length]
    end

    def to_hash
      {
        :data        => @data,
        :compression => @compression,
        :md5         => @md5,
        :file_url    => @file_url,
        :mime_type   => @mime_type,
        :length      => @length
      }.merge(super)
    end

    def to_json_hash
      {
        :objectType  => "binary",
        :data        => @data,
        :compression => @compression,
        :md5         => @md5,
        :fileUrl     => @file_url,
        :mimeType    => @mime_type,
        :length      => @length
      }.merge(super)
    end
  end
end

module Nelumba
  class File
    include Nelumba::Object

    attr_reader :file_url
    attr_reader :mime_type

    attr_reader :length
    attr_reader :md5

    def initialize(options = {}, &blk)
      init(options, &blk)
    end

    def init(options = {}, &blk)
      super options

      @md5         = options[:md5]
      @file_url    = options[:file_url]
      @mime_type   = options[:mime_type]
      @length      = options[:length]
    end

    def to_hash
      {
        :md5       => @md5,
        :file_url  => @file_url,
        :mime_type => @mime_type,
        :length    => @length
      }.merge(super)
    end

    def to_json_hash
      {
        :objectType  => "file",
        :md5         => @md5,
        :fileUrl     => @file_url,
        :mimeType    => @mime_type,
        :length      => @length
      }.merge(super)
    end
  end
end

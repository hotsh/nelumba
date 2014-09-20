module Nelumba
  class Video
    include Nelumba::Object

    # A fragment of HTML markup that, when embedded within another HTML page,
    # provides an interactive user-interface for viewing or listening to the
    # video stream.
    attr_reader :embed_code

    # A MediaLink to the video content itself.
    attr_reader :stream

    # Creates a new Video activity object.
    def initialize(options = {}, &blk)
      init(options, &blk)
    end

    def init(options = {}, &blk)
      super(options, &blk)

      @embed_code = options[:embed_code]
      @stream     = options[:stream]
    end

    # Returns a hash of all relevant fields.
    def to_hash
      {
        :embed_code => @embed_code,
        :stream     => @stream
      }.merge(super)
    end

    # Returns a hash of all relevant fields with JSON activity streams
    # conventions.
    def to_json_hash
      {
        :objectType => "video",
        :embedCode  => @embed_code,
        :stream     => @stream
      }.merge(super)
    end
  end
end

module Nelumba
  class Audio
    include Nelumba::Object

    # A fragment of HTML markup that, when embedded within another HTML page,
    # provides an interactive user-interface for viewing or listening to the
    # audio stream.
    attr_reader :embed_code

    # A MediaLink to the audio content itself.
    attr_reader :stream

    # Creates a new Audio activity object.
    def initialize(options = {})
      options ||= {}
      options[:type] = :audio

      super options

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
        :embedCode  => @embed_code,
        :stream     => @stream
      }.merge(super)
    end
  end
end

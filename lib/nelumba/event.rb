module Nelumba
  class Event
    include Nelumba::Object

    attr_reader :attending
    attr_reader :maybe_attending
    attr_reader :not_attending

    attr_reader :start_time
    attr_reader :end_time

    attr_reader :location

    def initialize(options = {}, &blk)
      init(options, &blk)
    end

    def init(options = {}, &blk)
      options ||= {}
      options[:type] = :event

      super options, &blk

      @attending       = options[:attending]       || []
      @maybe_attending = options[:maybe_attending] || []
      @not_attending   = options[:not_attending]   || []
      @start_time      = options[:start_time]
      @end_time        = options[:end_time]
      @location        = options[:location]
    end

    def to_hash
      {
        :attending       => @attending.dup,
        :maybe_attending => @maybe_attending.dup,
        :not_attending   => @not_attending.dup,

        :start_time      => @start_time,
        :end_time        => @end_time,

        :location        => @location
      }.merge(super)
    end

    def to_json_hash
      {
        :attending      => @attending.dup,
        :maybeAttending => @maybe_attending.dup,
        :notAttending   => @not_attending.dup,

        :startTime      => (@start_time && @start_time.utc.iso8601),
        :endTime        => (@end_time   && @end_time.utc.iso8601),

        :location       => @location
      }.merge(super)
    end
  end
end

module Nelumba
  class Service
    include Nelumba::Object

    def init(options = {}, &blk)
      options ||= {}
      options[:type] = :service

      super(options, &blk)
    end
  end
end

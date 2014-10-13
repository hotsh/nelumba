module Nelumba
  class Group
    include Nelumba::Object

    def init(options = {}, &blk)
      options ||= {}
      options[:type] = :group

      super options, &blk
    end
  end
end

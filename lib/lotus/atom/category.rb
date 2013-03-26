require 'lotus/category'

module Lotus
  require 'atom'

  module Atom
    # This class represents an Lotus Category object.
    class Category < ::Atom::Category
      require 'open-uri'

      attribute :'xml:base'
      attribute :'xml:lang'
      attribute :scheme
      attribute :term
      attribute :label

      def self.from_canonical(obj)
        hash = obj.to_hash
        if hash[:base]
          hash[:xml_base] = hash[:base]
        end
        if hash[:lang]
          hash[:xml_lang] = hash[:lang]
        end
        hash.delete :base
        hash.delete :lang
        self.new(hash)
      end

      def to_canonical
        Lotus::Category.new(:base   => self.xml_base,
                            :lang   => self.xml_lang,
                            :scheme => self.scheme,
                            :lable  => self.label,
                            :term   => self.term)
      end
    end
  end
end



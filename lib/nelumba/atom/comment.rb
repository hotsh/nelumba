module Nelumba
  require 'atom'
  require 'nelumba/atom/thread'

  module Atom
    # This class represents an ActivityStreams Comment object.
    class Comment
      include ::Atom::Xml::Parseable

      # The XML namespace that identifies the conforming specification.
      ACTIVITY_NAMESPACE = 'http://activitystrea.ms/spec/1.0/'

      # The XML namespace that identifies the conforming specification of 'thr'
      # elements.
      THREAD_NAMESPACE = "http://purl.org/syndication/thread/1.0"

      # The XML schema that identifies the conforming schema for objects.
      SCHEMA_ROOT = 'http://activitystrea.ms/schema/1.0/'

      add_extension_namespace :activity, ACTIVITY_NAMESPACE
      element 'activity:object-type'

      element :author, :class => Nelumba::Atom::Author
      element :content, :class => ::Atom::Content
      element :displayName
      element :id
      element :title
      element :url
      element :summary
      element :updated, :published, :class => DateTime, :content_only => true

      add_extension_namespace :thr, THREAD_NAMESPACE
      elements 'thr:in-reply-to', :class => Nelumba::Atom::Thread

      def initialize(o = {})
        o[:activity_object_type] = SCHEMA_ROOT + "comment"

        case o
        when XML::Reader
          o.read
          parse(o)
        when Hash
          o.each do |k, v|
            self.send("#{k.to_s}=", v)
          end
        else
          raise ArgumentError, "Got #{o.class} but expected a Hash or XML::Reader"
        end

        yield(self) if block_given?
      end

      def to_hash
        {
        }
      end

      def self.from_canonical(obj)
        entry_hash = obj.to_hash

        entry_hash.delete :text
        entry_hash.delete :html

        entry_hash[:id] = entry_hash[:uid]
        entry_hash.delete :uid

        entry_hash[:displayName] = entry_hash[:display_name]
        entry_hash.delete :display_name

        entry_hash[:thr_in_reply_to] = entry_hash[:in_reply_to].map do |t|
          Nelumba::Atom::Thread.new(:href => t.url,
                                  :ref  => t.uid)
        end
        entry_hash.delete :in_reply_to

        if entry_hash[:author]
          entry_hash[:author] = Nelumba::Atom::Author.from_canonical(entry_hash[:author])
        end

        node = XML::Node.new("content")
        node['type'] = "html"
        node << entry_hash[:content]

        xml = XML::Reader.string(node.to_s)
        xml.read
        entry_hash[:content] = ::Atom::Content.parse(xml)

        self.new entry_hash
      end

      def to_canonical
        to_hash
      end
    end
  end
end

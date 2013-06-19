module Lotus
  module Atom
    require 'atom'

    class Entry < ::Atom::Entry
      require 'lotus/activity'
      require 'lotus/author'
      require 'lotus/link'

      require 'lotus/atom/author'
      require 'lotus/atom/thread'
      require 'lotus/atom/link'
      require 'lotus/atom/comment'
      require 'lotus/atom/source'

      require 'libxml'

      # The XML namespace that identifies the conforming specification of 'thr'
      # elements.
      THREAD_NAMESPACE = "http://purl.org/syndication/thread/1.0"

      # The XML namespace that identifies the conforming specification.
      ACTIVITY_NAMESPACE = 'http://activitystrea.ms/spec/1.0/'

      # The XML schema that identifies the conforming schema for objects.
      SCHEMA_ROOT = 'http://activitystrea.ms/schema/1.0/'

      include ::Atom::SimpleExtensions

      add_extension_namespace :activity, ACTIVITY_NAMESPACE
      element 'activity:object-type'
      element 'activity:object'
      element 'activity:verb'
      element 'activity:target'

      add_extension_namespace :thr, THREAD_NAMESPACE
      elements 'thr:in-reply-to', :class => Lotus::Atom::Thread

      # This is for backwards compatibility with some implementations of Activity
      # Streams. It should not be generated for Atom representation of Activity
      # Streams (although it is used in JSON)
      element 'activity:actor', :class => Lotus::Atom::Author

      element :source, :class => Lotus::Atom::Source

      namespace ::Atom::NAMESPACE
      element :title, :id, :summary
      element :updated, :published, :class => DateTime, :content_only => true
      elements :links, :class => Lotus::Atom::Link

      elements :replies, :class => Lotus::Atom::Entry

      elements :shares, :class => Lotus::Atom::Author
      elements :likes, :class => Lotus::Atom::Author
      elements :mentions, :class => Lotus::Atom::Author

      elements :categories, :class => ::Atom::Category
      element :content, :class => ::Atom::Content
      element :author, :class => Lotus::Atom::Author

      def url
        if links.alternate
          links.alternate.href
        elsif links.self
          links.self.href
        else
          links.map.each do |l|
            l.href
          end.compact.first
        end
      end

      def link
        links.group_by { |l| l.rel.intern if l.rel }
      end

      def link= options
        links.clear << ::Atom::Link.new(options)
      end

      def self.from_canonical(obj)
        entry_hash = obj.to_hash

        # Ensure that the content type is encoded.
        object = obj.object

        if object.is_a? Lotus::Note
          title = object.title

          content = object.text
          content = object.html if object.html

          content_type = nil
          content_type = "html" if object.html
        elsif object.is_a? Lotus::Comment
          content = nil
          content_type = nil
          title = nil
          object = Lotus::Atom::Comment.from_canonical(object.to_hash)
          entry_hash[:activity_object] = object
        else
          content = nil
          content_type = nil
          title = nil
          entry_hash[:activity_object] = object if object.is_a? Lotus::Author
        end

        if content
          node = XML::Node.new("content")
          node['type'] = content_type if content_type
          node << content

          xml = XML::Reader.string(node.to_s)
          xml.read
          entry_hash[:content] = ::Atom::Content.parse(xml)
          entry_hash.delete :content_type
        end

        entry_hash[:title] = title if title

        if entry_hash[:source]
          entry_hash[:source] = Lotus::Atom::Source.from_canonical(entry_hash[:source])
        end

        if entry_hash[:actor]
          entry_hash[:author] = Lotus::Atom::Author.from_canonical(entry_hash[:actor])
        end
        entry_hash.delete :actor

        # Encode in-reply-to fields
        entry_hash[:thr_in_reply_to] = entry_hash[:in_reply_to].map do |t|
          Lotus::Atom::Thread.new(:href => t.url,
                                  :ref  => t.uid)
        end
        entry_hash.delete :in_reply_to

        entry_hash[:links] ||= []

        if entry_hash[:url]
          entry_hash[:links] << ::Atom::Link.new(:rel => "self", :href => entry_hash[:url])
        end
        entry_hash.delete :url

        object_type = entry_hash[:type]
        if object_type
          entry_hash[:activity_object_type] = SCHEMA_ROOT + object_type.to_s
        end
        if entry_hash[:verb]
          entry_hash[:activity_verb] = SCHEMA_ROOT + entry_hash[:verb].to_s
        end
        entry_hash[:activity_target] = entry_hash[:target] if entry_hash[:target]

        entry_hash[:id] = entry_hash[:uid]
        entry_hash.delete :uid

        entry_hash.delete :object
        entry_hash.delete :verb
        entry_hash.delete :target
        entry_hash.delete :type

        self.new(entry_hash)
      end

      def to_canonical
        # Reform the activity type
        # TODO: Add new Base schema verbs
        object_type = self.activity_object_type
        if object_type && object_type.start_with?(SCHEMA_ROOT)
          object_type.gsub!(/^#{Regexp.escape(SCHEMA_ROOT)}/, "")
        end

        object_type = "note" if object_type == "status"

        if self.activity_object
          object = self.activity_object.to_canonical
        else
          case object_type
          when "note"
            object = Lotus::Note.new(:html  => self.content.to_s,
                                     :title => self.title)
          end
        end

        source = self.source
        source = source.to_canonical if source
        Lotus::Activity.new(:actor        => self.author ? self.author.to_canonical : nil,
                            :uid          => self.id,
                            :url          => self.url,
                            :source       => source,
                            :in_reply_to  => self.thr_in_reply_to.map(&:to_canonical),
                            :link         => self.link,
                            :object       => object,
                            :type         => object_type,
                            :verb         => self.activity_verb,
                            :target       => self.activity_target,
                            :published    => self.published,
                            :updated      => self.updated)
      end
    end
  end
end

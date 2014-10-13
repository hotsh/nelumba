module Nelumba
  module Atom
    class Entry
      require 'libxml'

      # The XML namespace that identifies the conforming specification of 'thr'
      # elements.
      THREAD_NAMESPACE = "http://purl.org/syndication/thread/1.0"

      # The XML namespace that identifies the conforming specification.
      ACTIVITY_NAMESPACE = 'http://activitystrea.ms/spec/1.0/'

      # The XML schema that identifies the conforming schema for objects.
      SCHEMA_ROOT = 'http://activitystrea.ms/schema/1.0/'

      # The XML namespace that defines Atom
      ATOM_NAMESPACE = 'http://www.w3.org/2005/Atom'

      # The XML namespace that defines Portable Contacts
      POCO_NAMESPACE = 'http://portablecontacts.net/spec/1.0'

      # The XML namespace that defines OStatus specification
      OSTATUS_NAMESPACE = 'http://ostatus.org/schema/1.0'

      def self.to_canonical(xml_node_or_string, is_object = false)
        # NOTE: Implied posts should just be considered objects at first and then
        # wrapped in a constructed post activity where actor is author
        # This is kinda confusing-ish!

        if xml_node_or_string.is_a? XML::Node
          xml = xml_node_or_string
        else
          doc = XML::Parser.string(xml_node_or_string.to_s,
                                   :encoding => XML::Encoding::UTF_8).parse
          xml = doc.root
        end

        # Hmm. Pull out the first one if the root node isn't the right element.
        if xml && (xml.name != "entry" && xml.name != "object")
         xml = xml.find_first("//xmlns:entry", "xmlns:#{ATOM_NAMESPACE}")
        end

        # Parse this node
        hash   = {}
        object = {}

        if xml
          # Go through nodes here and parse out relevant information
          xml.each do |node|
            next if node.text?
            prefix = node.namespaces.namespace.prefix

            tag    = node.name
            tag    = "#{prefix}:#{tag}" if prefix

            case tag
            when "id"
              # Nelumba uses "id" key internally, external id uses "uid" key:
              object[:uid] = node.content.strip
            when "source"
              object[:source] = Nelumba::Atom::Feed.to_canonical(node)
            when "content"
              if node['type'] == 'html'
                object[:html] = node.content.strip
              elsif node['type'] == 'text'
                object[:text] = node.content.strip
              else
                object[:content] = node.content.strip
              end
            when "author", "activity:actor"
              object[:authors] ||= []
              object[:authors] << Nelumba::Atom::Author.to_canonical(node)
            when "title", "url"
              # These tags have 1:1 relationship with Nelumba metadata keys
              object[node.name.intern] = node.content.strip
            when "activity:object" # The object of the activity
              # We need to look into the node to know how to parse it!
              type = node.find_first("activity:object-type", "activity:#{ACTIVITY_NAMESPACE}")
              if type.content.strip == SCHEMA_ROOT + "person"
                hash[:object] = Nelumba::Atom::Author.to_canonical(node)
              else
                hash[:object] = Nelumba::Atom::Entry.to_canonical(node, true)
              end
            when "activity:object-type" # The noun of the object of the activity
              object[:type] = node.content.strip
              if object[:type].start_with? SCHEMA_ROOT
                object[:type].gsub!(/^#{Regexp.escape(SCHEMA_ROOT)}/, '')
              end
              object[:type] = object[:type].intern
              object[:type] = :note if object[:type] == :status
            when "thr:in-reply-to" # This activity is in-reply-to something
              object[:in_reply_to] ||= []
              object[:in_reply_to] << {
                :uid => node['ref'].strip,
                :url => node['href'].strip
              }
            when "activity:verb" # The verb (action) the activity is performing
              hash[:verb] = node.content.strip

              # Strip out activity streams schema stuff
              if hash[:verb].start_with? SCHEMA_ROOT
                hash[:verb].gsub!(/^#{Regexp.escape(SCHEMA_ROOT)}/, '')
              end

              hash[:verb] = hash[:verb].intern
            when "updated", "published"
              # Parse ISO8601 dates
              hash[node.name.intern] = Time.iso8601(node.content.strip)
            when "link"
              # Negotiate rel
              case node['rel']
              when "alternate"
                # an object's representative url
                if node['type'] == "text/html"
                  object[:url] = node['href'].strip
                elsif not object.has_key? :url
                  object[:url] = node['href'].strip
                end
              when "self"
                # the object's own representative atom url
                if node['type'] == "text/html"
                  object[:url] = node['href'].strip
                elsif not object.has_key? :url
                  object[:url] = node['href'].strip
                end
              when "related"
                # target_url for bookmark
                object[:target_url] = node['href'].strip
              end
            end
          end
        end

        if not hash.has_key? :type
          hash[:type] = :activity
        end

        if is_object or hash.has_key? :object
          hash.merge!(object)
        end

        if not is_object and not hash.has_key? :verb
          hash[:verb] = :post
        end

        if not is_object and not hash.has_key? :object
          if object.is_a? Hash
            object = case object[:type]
                     when :activity  # Base Activity
                       Nelumba::Activity.new(object)
                     when :note      # Notes
                       Nelumba::Note.new(object)
                     when :bookmark  # Bookmarks
                       Nelumba::Bookmark.new(object)
                     when :comment   # Comment
                       Nelumba::Comment.new(object)
                     else
                       Nelumba::Activity.new(object)
                     end
            hash[:type] = :activity
          end
          hash[:object] = object
        end

        if not is_object
          if not hash[:authors] and hash[:object]
            if hash[:object].respond_to?(:actors)
              hash[:authors] = hash[:object].actors
            elsif hash[:object].respond_to?(:authors)
              hash[:authors] = hash[:object].authors
            end
          end
          hash[:actors] = hash[:authors]
          hash.delete :authors
        end

        case hash[:type]
        when :activity  # Base Activity
          Nelumba::Activity.new(hash)
        when :note      # Notes
          Nelumba::Note.new(hash)
        when :bookmark  # Bookmarks
          Nelumba::Bookmark.new(hash)
        when :comment   # Comments
          Nelumba::Comment.new(hash)
        else
          Nelumba::Activity.new(hash)
        end
      end

      # Will produce the AS 1.0 XML representation and will work as best as
      # possible to allow AS 2.0 vocab and arbitrary vocab for discovery.
      #
      # It fits Atom conventions, as is fitting for this class notation!
      # Therefore, obvious Atom overlaps take precedence over AS specific
      # conventions. "post" verbs will simply coalesce to <entry> without
      # an <activity-object> because the absence of <activity-object> will
      # denote an implied "post" activity.
      #
      # For other cases, the verb will be specified and there will be an
      # <activity:object>, which will contain the same schema as an <entry>
      # within it.
      #
      # This is more-or-less the OStatus way of doing things.
      def self.from_canonical(activity, document = nil, no_embed = false)
        # Define our root
        root = XML::Node.new("entry")

        # Create a document container
        doc = document
        if document.nil?
          doc = XML::Document.new
          doc.encoding = XML::Encoding::UTF_8

          root.namespaces.namespace = XML::Namespace.new(root, nil, ATOM_NAMESPACE)

          # Define namespaces
          XML::Namespace.new(root, "activity", ACTIVITY_NAMESPACE)
          XML::Namespace.new(root, "ostatus",  OSTATUS_NAMESPACE)
          XML::Namespace.new(root, "poco",     POCO_NAMESPACE)
          XML::Namespace.new(root, "thr",      THREAD_NAMESPACE)
        end

        # Implied post?
        activity_object = nil
        if (no_embed || activity.verb != :post) && activity.respond_to?(:object) && activity.object
          # Do not embed the activity object. No implied post!
          if activity.object.is_a? Nelumba::Person
            activity_object = Nelumba::Atom::Author.from_canonical(activity.object, doc)
          else
            activity_object = Nelumba::Atom::Entry.from_canonical(activity.object, doc, true)
          end
          activity_object.name = "activity:object"
          root << activity_object
        end

        # Set <id>
        if activity_object.nil? && activity.respond_to?(:object) && activity.object && activity.object.uid
          root << XML::Node.new("id", activity.object.uid.to_s)
        elsif activity.uid
          root << XML::Node.new("id", activity.uid.to_s)
        end

        # Set <title>
        if activity_object.nil? && activity.respond_to?(:object) && activity.object && activity.object.title
          root << XML::Node.new("title", activity.object.title.to_s)
        elsif activity.title
          root << XML::Node.new("title", activity.title.to_s)
        end

        # Set <displayName>
        if activity_object.nil? && activity.respond_to?(:object) && activity.object && activity.object.display_name
          root << XML::Node.new("displayName", activity.object.display_name.to_s)
        elsif activity.uid
          root << XML::Node.new("displayName", activity.display_name.to_s)
        end

        # Set <source>
        if activity_object.nil? && activity.respond_to?(:object) && activity.object && activity.object.source
          root << Nelumba::Atom::Feed.from_canonical(activity.object.source, doc, true)
        elsif activity.source
          root << Nelumba::Atom::Feed.from_canonical(activity.source, doc, true)
        end

        # Set <activity:actor> by generating XML for an Atom::Person
        if activity_object.nil? && activity.respond_to?(:object) && activity.object && activity.object.authors
          activity.object.authors.each do |author|
            root << Nelumba::Atom::Author.from_canonical(author, doc)
          end
        elsif activity_object.nil? && activity.respond_to?(:object) && activity.object && activity.object.respond_to?(:actors) && activity.object.actors
          activity.object.actors.each do |actor|
            root << Nelumba::Atom::Author.from_canonical(actor, doc)
          end
        elsif activity.respond_to?(:actors) && activity.actors
          activity.actors.each do |actor|
            root << Nelumba::Atom::Author.from_canonical(actor, doc)
          end
        elsif activity.respond_to?(:authors) && activity.authors
          activity.authors.each do |author|
            root << Nelumba::Atom::Author.from_canonical(author, doc)
          end
        end

        # Set <activity:object-type> which means negotiating the right namespace
        # TODO: negotiate activity vocab and allow arbitrary verbs
        if activity_object.nil? && activity.respond_to?(:object) && activity.object && activity.object.type
          type = SCHEMA_ROOT + activity.object.type.to_s
          root << XML::Node.new("activity:object-type", type)
        elsif activity.type
          type = SCHEMA_ROOT + activity.type.to_s
          root << XML::Node.new("activity:object-type", type)
        end

        # Set <activity:verb> which means negotiating the right namespace
        if activity.respond_to?(:verb) && activity.verb
          # TODO: negotiate activity vocab and allow arbitrary verbs
          verb = SCHEMA_ROOT + activity.verb.to_s
          root << XML::Node.new("activity:verb", verb)
        end

        # Handle the content. Try html first.
        if activity_object.nil? && activity.respond_to?(:object) && activity.object
          if activity.object.html
            node = XML::Node.new("content", activity.object.html)
            node['type'] = 'html'
            root << node
          elsif activity.object.text
            node = XML::Node.new("content", activity.object.text)
            node['type'] = 'text'
            root << node
          end
        elsif activity.html
          node = XML::Node.new("content", activity.html)
          node['type'] = 'html'
          root << node
        elsif activity.text
          node = XML::Node.new("content", activity.text)
          node['type'] = 'text'
          root << node
        end

        # Set <published>
        if activity.published
          root << XML::Node.new("published", activity.published.utc.iso8601)
        end

        # Set <updated>
        if activity.updated
          root << XML::Node.new("updated", activity.updated.utc.iso8601)
        end

        # Attach links
        self_url = nil
        if activity_object.nil? and activity.respond_to?(:object) and activity.object and activity.object.url
          self_url = activity.object.url
        elsif activity.url
          self_url = activity.url
        end
        if self_url
          link = XML::Node.new("link")
          link['rel']  = 'self'
          link['type'] = 'application/atom+xml'
          link['href'] = self_url
          root << link
        end

        # In-Reply-To links
        in_reply_to = []
        if activity_object.nil? and activity.respond_to?(:object) and activity.object and activity.object.in_reply_to
          in_reply_to = activity.object.in_reply_to
        elsif activity.in_reply_to
          in_reply_to = activity.in_reply_to
        end
        in_reply_to.each do |obj|
          thr = XML::Node.new("thr:in-reply-to")
          thr['ref']  = obj.uid
          thr['href'] = obj.url
          root << thr
        end

        # Bookmark/etc target_url
        if activity.respond_to? :target_url and activity.target_url
          link = XML::Node.new("link")
          link['rel']  = 'target_url'
          link['href'] = activity.target_url
          root << link
        end

        # Render the xml text
        if document.nil?
          doc.root = root
          doc.to_s
        else
          root
        end
      end
    end
  end
end

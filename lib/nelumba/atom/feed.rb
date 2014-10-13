require 'nelumba/activity'
require 'nelumba/person'
require 'nelumba/category'
require 'nelumba/generator'

require 'nelumba/atom/entry'
require 'nelumba/atom/author'

module Nelumba
  module Atom
    # This class represents an OStatus Feed object.
    class Feed
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

      def self.to_canonical(xml_node_or_string)
        if xml_node_or_string.is_a? XML::Node
          xml = xml_node_or_string
        else
          doc = XML::Parser.string(xml_node_or_string.to_s,
                                   :encoding => XML::Encoding::UTF_8).parse
          xml = doc.root
        end

        # Hmm. Pull out the first one if the root node isn't the right element.
        if xml && xml.name != "feed" && xml.name != "source"
         xml = xml.find_first("//xmlns:feed", "xmlns:#{ATOM_NAMESPACE}")
        end

        # Parse this node
        hash = {}

        if xml
          # Go through nodes here and parse out relevant information
          xml.each do |node|
            next if node.text?
            next if node.comment?
            prefix = node.namespaces.namespace.prefix

            tag    = node.name
            tag    = "#{prefix}:#{tag}" if prefix

            case tag
            when "id"
              # Nelumba uses "id" key internally, external id uses "uid" key:
              hash[:uid] = node.content.strip
            when "title", "url", "rights", "logo", "icon", "subtitle"
              # These tags have 1:1 relationship with Nelumba metadata keys
              hash[node.name.intern] = node.content.strip
            when "entry"
              hash[:items] ||= []
              hash[:items] << Nelumba::Atom::Entry.to_canonical(node)
            when "author"
              hash[:authors] ||= []
              hash[:authors] << Nelumba::Atom::Author.to_canonical(node)
            when "updated", "published"
              # Parse ISO8601 dates
              hash[node.name.intern] = Time.iso8601(node.content.strip)
            when "source"
              hash[:source] = Nelumba::Atom::Feed.to_canonical(node)
            when "link"
              # Negotiate rel
              case node['rel']
              when "hub"
                # The hub location
                hash[:hubs] ||= []
                hash[:hubs] << node['href'].strip
              when "alternate"
                # feed's representative url
                if node['type'] == "text/html"
                  hash[:url] = node['href'].strip
                elsif not hash.has_key? :url
                  hash[:url] = node['href'].strip
                end
              when "self"
                # the feed's own representative atom url
                if node['type'] == "text/html"
                  hash[:url] = node['href'].strip
                elsif not hash.has_key? :url
                  hash[:url] = node['href'].strip
                end
              end
            end
          end
        end

        Nelumba::Feed.new(hash)
      end

      def self.from_canonical(feed, document = nil, as_source = false)
        # Define our root
        if as_source
          root = XML::Node.new("source")
        else
          root = XML::Node.new("feed")
        end

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

        # Set <id>
        if feed.uid
          root << XML::Node.new("id", feed.uid.to_s)
        end

        # Set <rights>
        if feed.rights
          root << XML::Node.new("rights", feed.rights)
        end

        # Set <logo>
        if feed.logo
          root << XML::Node.new("logo", feed.logo)
        end

        # Set <icon>
        if feed.icon
          root << XML::Node.new("icon", feed.icon)
        end

        # Set <published>
        if feed.published
          root << XML::Node.new("published", feed.published.utc.iso8601)
        end

        # Set <updated>
        if feed.updated
          root << XML::Node.new("updated", feed.updated.utc.iso8601)
        end

        # Set <subtitle>
        if feed.subtitle
          node = XML::Node.new("subtitle", feed.subtitle)
          node['type'] = feed.subtitle_type
          root << node
        end

        # Set <title>
        if feed.title
          node = XML::Node.new("title", feed.title)
          node['type'] = feed.title_type
          root << node
        end

        # Set <totalItems>
        if feed.items
          root << XML::Node.new("totalItems", feed.items.count.to_s)
        end

        # Add <author>
        if feed.authors
          feed.authors.each do |author|
            root << Nelumba::Atom::Author.from_canonical(author, doc)
          end
        end

        # Set <source>
        if not as_source and feed.source
          root << Nelumba::Atom::Feed.from_canonical(feed.source, doc, true)
        end

        # Attach links
        if feed.url
          link = XML::Node.new("link")
          link['rel']  = 'self'
          link['type'] = 'application/atom+xml'
          link['href'] = feed.url
          root << link
        end

        if feed.hubs
          feed.hubs.each do |hub|
            link = XML::Node.new("link")
            link['rel']  = 'hub'
            link['href'] = hub
            root << link
          end
        end

        # All <entry> elements from items
        if not as_source and feed.items
          feed.items.each do |item|
            root << Nelumba::Atom::Entry.from_canonical(item, doc)
          end
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

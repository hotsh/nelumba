module Nelumba
  module Atom
    # Holds information about the author of the Feed.
    class Author
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
        if xml && (xml.name != "author" &&
                   xml.name != "object" &&
                   xml.name != "actor")
         xml = xml.find_first("//xmlns:author", "xmlns:#{ATOM_NAMESPACE}")
        end

        # Parse this node
        hash = {}

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
              hash[:uid] = node.content.strip
            when "email", "name", "uri"
              # These tags have 1:1 relationship with Nelumba metadata keys
              hash[node.name.intern] = node.content.strip
            when "updated", "published"
              # Parse ISO8601 dates
              hash[node.name.intern] = Time.iso8601(node.content.strip)
            when /^poco\:/
              # poco:*
              case node.name
              when "birthday", "anniversary"
                hash[node.name.intern] = Date.iso8601(node.content.strip)
              when "id"
                # Only allow this as a fallback id
                hash[:uid] = node.content.strip if !hash.has_key? :uid
              when "updated", "published"
                # Parse ISO8601 dates (only as fallback)
                if !hash.has_key? node.name.intern
                  hash[node.name.intern] = Time.iso8601(node.content.strip)
                end
              when "nickname", "gender", "note"
                hash[node.name.intern] = node.content.strip
              when "displayName"
                hash[:display_name] = node.content.strip
              when "preferredUsername"
                hash[:preferred_username] = node.content.strip
              when "address"
                # Parse the inner tags
                inner_hash = {}
                node.each do |node|
                  case node.name
                  when "formatted", "locality", "region", "country"
                    inner_hash[node.name.intern] = node.content.strip
                  when "streetAddress"
                    inner_hash[:street_address] = node.content.strip
                  when "postalCode"
                    inner_hash[:postal_code] = node.content.strip
                  end
                end
                hash[:address] = inner_hash
              when "organization"
                # Parse the inner tags
                inner_hash = {}
                node.each do |node|
                  case node.name
                  when "name", "department", "title", "type",
                       "location", "description"
                    inner_hash[node.name.intern] = node.content.strip
                  when "startDate"
                    inner_hash[:start_date] = Date.iso8601(node.content.strip)
                  when "endDate"
                    inner_hash[:end_date] = Date.iso8601(node.content.strip)
                  end
                end
                hash[:organization] = inner_hash
              when "name"
                # Parse the inner tags
                inner_hash = {}
                node.each do |node|
                  case node.name
                  when "formatted"
                    inner_hash[node.name.intern] = node.content.strip
                  when "familyName"
                    inner_hash[:family_name] = node.content.strip
                  when "givenName"
                    inner_hash[:given_name] = node.content.strip
                  when "middleName"
                    inner_hash[:middle_name] = node.content.strip
                  when "honorificPrefix"
                    inner_hash[:honorific_prefix] = node.content.strip
                  when "honorificSuffix"
                    inner_hash[:honorific_suffix] = node.content.strip
                  end
                end
                hash[:extended_name] = inner_hash
              when "account"
                # Parse the inner tags
                inner_hash = {}
                node.each do |node|
                  case node.name
                  when "domain", "username", "userid"
                    inner_hash[node.name.intern] = node.content.strip
                  end
                end
                hash[:account] = inner_hash
              end
            when "link"
              # Negotiate rel
            end
          end
        end

        Nelumba::Person.new(hash)
      end

      def self.from_canonical(activity, document = nil)
        # Create a root
        root = XML::Node.new("author")

        # Create a document container
        doc = document
        if document.nil?
          doc = XML::Document.new
          doc.encoding = XML::Encoding::UTF_8

          # Define our root namespaces
          root.namespaces.namespace = XML::Namespace.new(root, nil, ATOM_NAMESPACE)

          # Define namespaces
          XML::Namespace.new(root, "activity", ACTIVITY_NAMESPACE)
          XML::Namespace.new(root, "ostatus",  OSTATUS_NAMESPACE)
          XML::Namespace.new(root, "poco",     POCO_NAMESPACE)
          XML::Namespace.new(root, "thr",      THREAD_NAMESPACE)
        end

        # Set <id> and <poco:id>
        if activity.uid
          root << XML::Node.new("poco:id", activity.uid.to_s)
          root << XML::Node.new("id",      activity.uid.to_s)
        end

        # Set <uri>
        if activity.uri
          root << XML::Node.new("uri", activity.uri.to_s)
        end

        # Set <name>
        if activity.name
          root << XML::Node.new("name", activity.name.to_s)
        end

        # poco:* fields
        # TODO: move to a PortableContacts class maybe
        if activity.display_name
          root << XML::Node.new("poco:displayName",
                                activity.display_name.to_s)
        end

        # Set <poco:preferredUsername>
        if activity.preferred_username
          root << XML::Node.new("poco:preferredUsername",
                                activity.preferred_username.to_s)
        end

        # Set <poco:note>
        if activity.note
          root << XML::Node.new("poco:note",
                                activity.note.to_s)
        end

        # Set <poco:address>
        if activity.address
          hash = activity.address
          address = XML::Node.new("poco:address")
          if hash.has_key? :formatted
            address << XML::Node.new("poco:formatted", hash[:formatted])
          end

          if hash.has_key? :street_address
            address << XML::Node.new("poco:streetAddress", hash[:street_address])
          end

          if hash.has_key? :locality
            address << XML::Node.new("poco:locality", hash[:locality])
          end

          if hash.has_key? :region
            address << XML::Node.new("poco:region", hash[:region])
          end

          if hash.has_key? :postal_code
            address << XML::Node.new("poco:postalCode", hash[:postal_code])
          end

          if hash.has_key? :country
            address << XML::Node.new("poco:country", hash[:country])
          end
          root << address
        end

        # Set <poco:organization>
        if activity.organization
          hash = activity.organization
          organization = XML::Node.new("poco:organization")
          if hash.has_key? :name
            organization << XML::Node.new("poco:name", hash[:name])
          end

          if hash.has_key? :department
            organization << XML::Node.new("poco:department", hash[:department])
          end

          if hash.has_key? :title
            organization << XML::Node.new("poco:title", hash[:title])
          end

          if hash.has_key? :type
            organization << XML::Node.new("poco:type", hash[:type])
          end

          if hash.has_key? :start_date
            organization << XML::Node.new("poco:startDate",
                                          hash[:start_date].iso8601)
          end

          if hash.has_key? :end_date
            organization << XML::Node.new("poco:endDate",
                                          hash[:end_date].iso8601)
          end

          if hash.has_key? :location
            organization << XML::Node.new("poco:location", hash[:location])
          end

          if hash.has_key? :description
            organization << XML::Node.new("poco:description", hash[:description])
          end
          root << organization
        end

        # Set <poco:name>
        if activity.extended_name
          hash = activity.extended_name
          name = XML::Node.new("poco:name")
          if hash.has_key? :formatted
            name << XML::Node.new("poco:formatted", hash[:formatted])
          end
          if hash.has_key? :family_name
            name << XML::Node.new("poco:familyName", hash[:family_name])
          end
          if hash.has_key? :given_name
            name << XML::Node.new("poco:givenName", hash[:given_name])
          end
          if hash.has_key? :middle_name
            name << XML::Node.new("poco:middleName", hash[:middle_name])
          end
          if hash.has_key? :honorific_prefix
            name << XML::Node.new("poco:honorificPrefix", hash[:honorific_prefix])
          end
          if hash.has_key? :honorific_suffix
            name << XML::Node.new("poco:honorificSuffix", hash[:honorific_suffix])
          end
          root << name
        end

        # Set <poco:account>
        if activity.account
          hash = activity.account
          account = XML::Node.new("poco:account")
          if hash.has_key? :domain
            account << XML::Node.new("poco:domain", hash[:domain])
          end

          if hash.has_key? :username
            account << XML::Node.new("poco:username", hash[:username])
          end

          if hash.has_key? :userid
            account << XML::Node.new("poco:userid", hash[:userid])
          end
          root << account
        end

        # Set <poco:anniversary>
        if activity.anniversary
          # TODO: ensure this date is formatted correctly
          root << XML::Node.new("poco:anniversary", activity.anniversary.iso8601)
        end

        if activity.birthday
          # TODO: ensure this date is formatted correctly
          root << XML::Node.new("poco:birthday", activity.birthday.iso8601)
        end

        # Set <email>
        if activity.email
          root << XML::Node.new("email", activity.email)
        end

        # Set <poco:gender>
        if activity.gender
          root << XML::Node.new("poco:gender", activity.gender)
        end

        # Set <poco:nickname>
        if activity.nickname
          root << XML::Node.new("poco:nickname", activity.nickname)
        end

        # Set <activity:object-type> which means negotiating the right namespace
        root << XML::Node.new("activity:object-type", SCHEMA_ROOT + "person")

        # Set <published> and <poco:published>
        if activity.published
          root << XML::Node.new("published", activity.published.utc.iso8601)
          root << XML::Node.new("poco:published", activity.published.utc.iso8601)
        end

        # Set <updated> and <poco:updated>
        if activity.updated
          root << XML::Node.new("updated", activity.updated.utc.iso8601)
          root << XML::Node.new("poco:updated", activity.updated.utc.iso8601)
        end

        # Attach links
        if activity.uri
          link = XML::Node.new("link")
          link['rel']  = 'self'
          link['type'] = 'application/atom+xml'
          link['href'] = activity.uri
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

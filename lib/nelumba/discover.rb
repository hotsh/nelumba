module Nelumba
  module Discover
    require 'nelumba/atom/feed'
    require 'net/http'
    require 'nokogiri'

    # The order to respect atom links
    MIME_ORDER = ['application/atom+xml',
                  'application/rss+xml',
                  'application/xml']

    # Will yield an OStatus::Identity for the given fully qualified name
    # (i.e. "user@domain.tld")
    def self.identity(name)
      xrd = nil

      if name.match /^https?:\/\//
        url = name
        type = 'text/html'
        response = Nelumba::Discover.pull_url(url, type)

        # Look at HTTP link headers
        if response["Link"]
          link = response["Link"]

          new_url = link[/^<([^>]+)>/,1]
          rel     = link[/;\s*rel\s*=\s*"([^"]+)"/,1]
          type    = link[/;\s*type\s*=\s*"([^"]+)"/,1]

          if new_url.start_with? "/"
            domain = url[/^(http[s]?:\/\/[^\/]+)\//,1]
            new_url = "#{domain}#{new_url}"
          end

          if rel == "lrdd"
            Nelumba::Discover.identity_from_xml(new_url)
          else
            nil
          end
        end
      elsif name.match /@/
        Nelumba::Discover.identity_from_webfinger(name)
      end
    end

    # Retrieves a Nelumba::Identity from the given webfinger account.
    def self.identity_from_webfinger(acct)
      # We allow a port, unusually. Some exaxmples:
      #
      # acct: 'acct:wilkie@example.org:9292'
      #   or: 'acct:wilkie@example.org'
      #   or: 'wilkie@example.org'

      # Remove acct: prefix if it exists
      acct.gsub!(/^acct\:/, "")

      # Get domain and port
      matches = acct.match /([^@]+)@([^:]+)(:\d+)?$/
      username = matches[1]
      domain   = matches[2]
      port     = matches[3] || "" # will include the ':'

      accept = ['application/xml+xrd',
                'application/xml',
                'text/html']

      # Pull .well-known/host-meta
      scheme = 'https'
      url = "#{scheme}://#{domain}#{port}/.well-known/host-meta"
      host_meta = Nelumba::Discover.pull_url(url, accept)

      if host_meta.nil?
        # TODO: Should we do this? probably not. ugh. but we must.
        scheme = 'http'
        url = "#{scheme}://#{domain}#{port}/.well-known/host-meta"
        puts url
        host_meta = Nelumba::Discover.pull_url(url, accept)
      end

      return nil if host_meta.nil?

      # Read xrd template location
      host_meta = host_meta.body
      host_meta = Nokogiri::XML(host_meta)
      links = host_meta.xpath("/xmlns:XRD/xmlns:Link")
      link = links.select{|link| link.attr('rel') == 'lrdd' }.first
      lrdd_template = link.attr('template') || link.attr('href')
      puts lrdd_template

      xrd_url = lrdd_template.gsub(/{uri}/, "acct:#{username}")

      xrd = Nelumba::Discover.pull_url(xrd_url, accept)
      return nil if xrd.nil?

      xrd = xrd.body
      xrd = Nokogiri::XML(xrd)

      unless xrd
        # TODO: Error
        return nil
      end

      # magic-envelope public key
      public_key = find_link(xrd, 'magic-public-key') || ""
      public_key = public_key.split(",")[1] || ""

      # ostatus notification endpoint
      salmon_url = find_link(xrd, 'salmon')

      # pump.io authentication endpoint
      dialback_url = find_link(xrd, 'dialback')

      # pump.io activity endpoints
      activity_inbox_endpoint = find_link(xrd, 'activity-inbox')
      activity_outbox_endpoint = find_link(xrd, 'activity-outbox')

      # profile page
      profile_page = find_link(xrd, 'http://webfinger.net/rel/profile-page')

      Identity.new(:public_key               => public_key,
                   :profile_page             => profile_page,
                   :salmon_endpoint          => salmon_url,
                   :dialback_endpoint        => dialback_url,
                   :activity_inbox_endpoint  => activity_inbox_endpoint,
                   :activity_outbox_endpoint => activity_outbox_endpoint)
    end

    # Retrieves a Nelumba::Identity from the given xml. You specify the xml
    # as a url, which will be retrieved and then parsed.
    def self.identity_from_xml(url, content_type = nil)
      content_type ||= ['application/xml+xrd',
                        'application/xml']

      xml = Nelumba::Discover.pull_url(url, content_type)
      return nil if xml.nil?

      Nelumba::Discover.identity_from_xml_string(xml)
    end

    def self.identity_from_xml_string(xml)
      xrd = Nokogiri::XML(xml)
      unless xrd
        # TODO: Error
        return nil
      end

      # magic-envelope public key
      public_key = find_link(xrd, 'magic-public-key')
      public_key = public_key.split(",")[1] || ""

      # ostatus notification endpoint
      salmon_url = find_link(xrd, 'salmon')

      # pump.io authentication endpoint
      dialback_url = find_link(xrd, 'dialback')

      # pump.io activity endpoints
      activity_inbox_endpoint = find_link(xrd, 'activity-inbox')
      activity_outbox_endpoint = find_link(xrd, 'activity-outbox')

      # profile page
      profile_page = find_link(xrd, 'http://webfinger.net/rel/profile-page')

      Identity.new(:public_key               => public_key,
                   :profile_page             => profile_page,
                   :salmon_endpoint          => salmon_url,
                   :dialback_endpoint        => dialback_url,
                   :activity_inbox_endpoint  => activity_inbox_endpoint,
                   :activity_outbox_endpoint => activity_outbox_endpoint)
    end

    # Will yield an Nelumba::Person for the given person.
    #
    # identity: Can be a String containing a fully qualified name (i.e.
    # "user@domain.tld") or a previously resolved Nelumba::Identity.
    def self.person(identity)
      if identity.is_a? String
        identity = Nelumba::Discover.identity(identity)
      end

      return nil if identity.nil? || identity.profile_page.nil?

      # Discover Person information

      # Pull profile page
      # Look for a feed to pull
      feed = Nelumba::Discover.feed(identity.profile_page)
      feed.authors.first
    end

    # Will yield a Nelumba::Feed object representing the feed at the given url
    # or identity.
    #
    # Usage:
    #   feed = Nelumba::Discover.feed("https://rstat.us/users/wilkieii/feed")
    #
    #   i = Nelumba::Discover.identity("wilkieii@rstat.us")
    #   feed = Nelumba::Discover.feed(i)
    def self.feed(url_or_identity, content_type = nil)
      if url_or_identity =~ /^(?:acct:)?[^@]+@[^@]+\.[^@]+$/
        url_or_identity = Nelumba::Discover.identity(url_or_identity)
      end

      if url_or_identity.is_a? Nelumba::Identity
        return Nelumba::Discover.feed(url_or_identity.profile_page)
      end

      # Atom is default type to attempt to retrieve
      content_type ||= ["application/atom+xml", "text/html"]
      accept = content_type

      url = url_or_identity

      if url =~ /^http[s]?:\/\//
        # Url is an internet resource
        response = Nelumba::Discover.pull_url(url, accept)

        return nil unless response.is_a?(Net::HTTPSuccess)

        content_type = response.content_type
        str = response.body
      else
        str = open(url).read
      end

      case content_type
      when 'application/atom+xml', 'application/rss+xml', 'application/xml',
           'xml', 'atom', 'rss', 'atom+xml', 'rss+xml'
        xml_str = str

        self.feed_from_string(xml_str, content_type)
      when 'text/html'
        html_str = str

        # Discover the feed
        doc = Nokogiri::HTML::Document.parse(html_str)
        links = doc.xpath("//link[@rel='alternate']").map {|el|
          {:type => el.attributes['type'].to_s,
           :href => el.attributes['href'].to_s}
        }.select{|e|
          MIME_ORDER.include? e[:type]
        }.sort {|a, b|
          MIME_ORDER.index(a[:type]) <=>
          MIME_ORDER.index(b[:type])
        }

        return nil if links.empty?

        # Resolve relative links
        link = URI::parse(links.first[:href]) rescue URI.new

        unless link.scheme
          link.scheme = URI::parse(url).scheme
        end

        unless link.host
          link.host = URI::parse(url).host rescue nil
        end

        unless link.absolute?
          link.path = File::dirname(URI::parse(url).path) \
            + '/' + link.path rescue nil
        end

        url = link.to_s
        Nelumba::Discover.feed(url, links.first[:type])
      end
    end

    # Yield a Nelumba::Feed from the given string content.
    def self.feed_from_string(string, content_type = nil)
      # Atom is default type to attempt to retrieve
      content_type ||= "application/atom+xml"

      case content_type
      when 'application/atom+xml', 'application/rss+xml', 'application/xml'
        Nelumba::Atom::Feed.new(XML::Reader.string(string)).to_canonical
      end
    end

    def self.activity(url)
      self.activity_from_url(url)
    end

    # Yield a Nelumba::Activity from the given url.
    def self.activity_from_url(url, content_type = nil)
      # Atom is default type to attempt to retrieve
      content_type ||= "application/atom+xml"

      response = Nelumba::Discover.pull_url(url, content_type)

      return nil unless response.is_a?(Net::HTTPSuccess)

      content_type = response.content_type

      case content_type
      when 'application/atom+xml', 'application/rss+xml', 'application/xml'
        xml_str = response.body
        self.entry_from_string(xml_str, response.content_type)
      end
    end

    # Yield a Nelumba::Activity from the given string content.
    def self.activity_from_string(string, content_type = "application/atom+xml")
      content_type ||= "application/atom+xml"

      case content_type
      when 'application/atom+xml', 'application/rss+xml', 'application/xml'
        Nelumba::Atom::Entry.new(XML::Reader.string(string)).to_canonical
      end
    end

    private

    # :nodoc:
    def self.pull_url(url, accept = nil, limit = 10)
      # Atom is default type to attempt to retrieve
      accept ||= ["application/atom+xml",
                  "application/xml"]

      if accept.is_a? String
        accept = [accept]
      end

      uri = URI(url)
      request = Net::HTTP::Get.new(uri.request_uri)
      request['Accept'] = accept.join(',')

      http = Net::HTTP.new(uri.hostname, uri.port)
      if uri.scheme == 'https'
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      end

      begin
        response = http.request(request)
      rescue OpenSSL::SSL::SSLError
        return nil
      end

      if response.is_a?(Net::HTTPRedirection) && limit > 0
        location = response['location']
        Nelumba::Discover.pull_url(location, accept, limit - 1)
      else
        response
      end
    end

    # :nodoc:
    def self.find_link(xrd, rel)
      links = xrd.xpath("/xmlns:XRD/xmlns:Link")
      link = links.select{|link| link.attr('rel').downcase == rel }.first
      return nil if link.nil?
      link.attr('template') || link.attr('href')
    end
  end
end

# Base Activity Objects
require 'nelumba/object'
require 'nelumba/activity'
require 'nelumba/collection'

# Activity Objects
require 'nelumba/article'
require 'nelumba/audio'
require 'nelumba/badge'
require 'nelumba/binary'
require 'nelumba/bookmark'
require 'nelumba/comment'
require 'nelumba/device'
require 'nelumba/event'
require 'nelumba/file'
require 'nelumba/group'
require 'nelumba/image'
require 'nelumba/note'
require 'nelumba/place'
require 'nelumba/question'
require 'nelumba/review'
require 'nelumba/service'
require 'nelumba/video'

# Data Structures
require 'nelumba/feed'
require 'nelumba/person'
require 'nelumba/identity'
require 'nelumba/notification'
require 'nelumba/link'

# Crypto
require 'nelumba/crypto'

# Pub-Sub
require 'nelumba/subscription'
require 'nelumba/publisher'

# This module contains elements that allow federated interaction. It also
# contains methods to construct these objects from external sources.
module Nelumba
  require 'libxml'

  # This module isolates Atom generation.
  module Atom; end

  require 'nelumba/atom/feed'
  require 'net/http'
  require 'redfinger'

  # The order to respect atom links
  MIME_ORDER = ['application/atom+xml',
                'application/rss+xml',
                'application/xml']

  # Will yield an OStatus::Identity for the given fully qualified name
  # (i.e. "user@domain.tld")
  def self.discover_identity(name)
    xrd = nil

    if name.match /^https?:\/\//
      url = name
      type = 'text/html'
      response = Nelumba::pull_url(url, type)

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
          xml = Nelumba::pull_url(new_url, type)
          xrd = Redfinger::Finger.new("xrd_from_profile", xml)
        end
      end
    elsif name.match /@/
      xrd = Redfinger.finger(name)
    end

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

    Identity.new(:public_key        => public_key,
                 :profile_page      => profile_page,
                 :salmon_endpoint   => salmon_url,
                 :dialback_endpoint => dialback_url,
                 :activity_inbox_endpoint => activity_inbox_endpoint,
                 :activity_outbox_endpoint => activity_outbox_endpoint)
  end

  # Will yield an Nelumba::Person for the given person.
  #
  # identity: Can be a String containing a fully qualified name (i.e.
  # "user@domain.tld") or a previously resolved Nelumba::Identity.
  def self.discover_person(identity)
    if identity.is_a? String
      identity = self.discover_identity(identity)
    end

    return nil if identity.nil? || identity.profile_page.nil?

    # Discover Person information

    # Pull profile page
    # Look for a feed to pull
    feed = self.discover_feed(identity.profile_page)
    feed.authors.first
  end

  # Will yield a Nelumba::Feed object representing the feed at the given url
  # or identity.
  #
  # Usage:
  #   feed = Nelumba.discover_feed("https://rstat.us/users/wilkieii/feed")
  #
  #   i = Nelumba.discover_identity("wilkieii@rstat.us")
  #   feed = Nelumba.discover_feed(i)
  def self.discover_feed(url_or_identity, content_type = "application/atom+xml")
    if url_or_identity =~ /^(?:acct:)?[^@]+@[^@]+\.[^@]+$/
      url_or_identity = Nelumba::discover_identity(url_or_identity)
    end

    if url_or_identity.is_a? Nelumba::Identity
      return self.discover_feed(url_or_identity.profile_page)
    end

    # Atom is default type to attempt to retrieve
    content_type ||= "application/atom+xml"

    url = url_or_identity

    if url =~ /^http[s]?:\/\//
      # Url is an internet resource
      response = Nelumba::pull_url(url, content_type)

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
      self.discover_feed(url, links.first[:type])
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

  def self.discover_activity(url)
    self.activity_from_url(url)
  end

  # Yield a Nelumba::Activity from the given url.
  def self.activity_from_url(url, content_type = nil)
    # Atom is default type to attempt to retrieve
    content_type ||= "application/atom+xml"

    response = Nelumba.pull_url(url, content_type)

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
  def self.pull_url(url, content_type = nil, limit = 10)
    # Atom is default type to attempt to retrieve
    content_type ||= "application/atom+xml"

    uri = URI(url)
    request = Net::HTTP::Get.new(uri.request_uri)
    request['Accept'] = content_type
    request.content_type = content_type

    http = Net::HTTP.new(uri.hostname, uri.port)
    if uri.scheme == 'https'
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    end

    response = http.request(request)

    if response.is_a?(Net::HTTPRedirection) && limit > 0
      location = response['location']
      Nelumba.pull_url(location, content_type, limit - 1)
    else
      response
    end
  end

  # :nodoc:
  def self.find_link(xrd, rel)
    link = xrd.links.find {|l| l['rel'].downcase == rel} || {}
    link.fetch("href") { nil }
  end
end

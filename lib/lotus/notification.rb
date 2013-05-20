module Lotus
  # This represents a notification that can be sent to a server when you wish
  # to send information to a server that has not yet subscribed to you. Since
  # this implies a lack of trust, a notification adds a layer so that the
  # recipiant can verify the message contents.
  class Notification
    require 'xml'
    require 'digest/sha2'

    # The Activity that is represented by this notification.
    attr_reader :activity

    # The identity of the sender that can be used to discover the Identity
    attr_reader :account

    # Create an instance for a particular Lotus::Activity.
    def initialize activity, signature = nil, plaintext = nil
      @activity = activity
      @signature = signature
      @plaintext = plaintext

      account = activity.actor.uri

      # XXX: Negotiate various weird uri schemes to find identity account
      @account = account
    end

    # Creates an activity for following a particular Author.
    def self.from_follow(user_author, followed_author)
      activity = Lotus::Activity.new(
        :verb => :follow,
        :object => followed_author,
        :actor    => user_author,
        :title    => "Now following #{followed_author.name}",
        :content  => "Now following #{followed_author.name}",
        :content_type => "html"
      )

      self.new(activity)
    end

    # Creates an activity for unfollowing a particular Author.
    def self.from_unfollow(user_author, followed_author)
      activity = Lotus::Activity.new(
        :verb => "http://ostatus.org/schema/1.0/unfollow",
        :object => followed_author,
        :actor    => user_author,
        :title => "Stopped following #{followed_author.name}",
        :content => "Stopped following #{followed_author.name}",
        :content_type => "html"
      )

      self.new(activity)
    end

    # Creates an activity for a profile update.
    def self.from_profile_update(user_author)
      activity = Lotus::Activity.new(
        :verb => "http://ostatus.org/schema/1.0/update-profile",
        :actor    => user_author,
        :title => "#{user_author.name} changed their profile information.",
        :content => "#{user_author.name} changed their profile information.",
        :content_type => "html"
      )

      self.new(activity)
    end

    # Will pull a Lotus::Activity from the given payload and MIME type.
    def self.from_data(content, content_type)
      case content_type
      when 'xml',
           'magic-envelope+xml',
           'application/xml',
           'application/text+xml',
           'application/magic-envelope+xml'
        self.from_xml content
      when 'json',
           'magic-envelope+json',
           'application/json',
           'application/text+json',
           'application/magic-envelope+json'
        self.from_json content
      end
    end

    # Will pull a Lotus::Activity from a magic envelope described by the JSON.
    def self.from_json(source)
    end

    # Will pull a Lotus::Activity from a magic envelope described by the XML.
    def self.from_xml(source)
      if source.is_a?(String)
        if source.length == 0
          return nil
        end

        source = XML::Document.string(source,
                                      :options => XML::Parser::Options::NOENT)
      else
        return nil
      end

      # Retrieve the envelope
      envelope = source.find('/me:env',
                             'me:http://salmon-protocol.org/ns/magic-env').first

      return nil unless envelope

      data = envelope.find('me:data',
                           'me:http://salmon-protocol.org/ns/magic-env').first
      return nil unless data

      data_type = data.attributes["type"]
      if data_type.nil?
        data_type = 'application/atom+xml'
        armored_data_type = ''
      else
        armored_data_type = Base64::urlsafe_encode64(data_type)
      end

      encoding = envelope.find('me:encoding',
                               'me:http://salmon-protocol.org/ns/magic-env').first

      algorithm = envelope.find(
                          'me:alg',
                          'me:http://salmon-protocol.org/ns/magic-env').first

      signature = source.find('me:sig',
                           'me:http://salmon-protocol.org/ns/magic-env').first

      # Parse fields

      # Well, if we cannot verify, we don't accept
      return nil unless signature

      # XXX: Handle key_id attribute
      signature = signature.content
      signature = Base64::urlsafe_decode64(signature)

      if encoding.nil?
        # When the encoding is omitted, use base64url
        # Cite: Magic Envelope Draft Spec Section 3.3
        armored_encoding = ''
        encoding = 'base64url'
      else
        armored_encoding = Base64::urlsafe_encode64(encoding.content)
        encoding = encoding.content.downcase
      end

      if algorithm.nil?
        # When algorithm is omitted, use 'RSA-SHA256'
        # Cite: Magic Envelope Draft Spec Section 3.3
        armored_algorithm = ''
        algorithm = 'rsa-sha256'
      else
        armored_algorithm = Base64::urlsafe_encode64(algorithm.content)
        algorithm = algorithm.content.downcase
      end

      # Retrieve and decode data payload

      data = data.content
      armored_data = data

      case encoding
      when 'base64url'
        data = Base64::urlsafe_decode64(data)
      else
        # Unsupported data encoding
        return nil
      end

      # Signature plaintext
      plaintext = "#{armored_data}.#{armored_data_type}.#{armored_encoding}.#{armored_algorithm}"

      # Interpret data payload
      payload = XML::Reader.string(data)
      self.new Lotus::Atom::Entry.new(payload).to_canonical, signature, plaintext
    end

    # Generate the xml for this notice and sign with the given private key.
    def to_xml private_key
      # Generate magic envelope
      magic_envelope = XML::Document.new

      magic_envelope.root = XML::Node.new 'env'

      me_ns = XML::Namespace.new(magic_envelope.root,
                   'me', 'http://salmon-protocol.org/ns/magic-env')

      magic_envelope.root.namespaces.namespace = me_ns

      # Armored Data <me:data>
      data = @activity.to_atom
      @plaintext = data
      data_armored = Base64::urlsafe_encode64(data)
      elem = XML::Node.new 'data', data_armored, me_ns
      elem.attributes['type'] = 'application/atom+xml'
      data_type_armored = 'YXBwbGljYXRpb24vYXRvbSt4bWw='
      magic_envelope.root << elem

      # Encoding <me:encoding>
      magic_envelope.root << XML::Node.new('encoding', 'base64url', me_ns)
      encoding_armored = 'YmFzZTY0dXJs'

      # Signing Algorithm <me:alg>
      magic_envelope.root << XML::Node.new('alg', 'RSA-SHA256', me_ns)
      algorithm_armored = 'UlNBLVNIQTI1Ng=='

      # Signature <me:sig>
      plaintext =
        "#{data_armored}.#{data_type_armored}.#{encoding_armored}.#{algorithm_armored}"

      # Assign @signature to the signature generated from the plaintext
      @signature = Lotus::Crypto.emsa_sign(plaintext, private_key)

      signature_armored = Base64::urlsafe_encode64(@signature)
      magic_envelope.root << XML::Node.new('sig', signature_armored, me_ns)

      magic_envelope.to_s :indent => true, :encoding => XML::Encoding::UTF_8
    end

    # Check the origin of this notification.
    def verified? key
      Lotus::Crypto.emsa_verify(@plaintext, @signature, key)
    end
  end
end

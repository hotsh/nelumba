module Lotus
  class Subscription
    require 'net/http'
    require 'uri'
    require 'base64'
    require 'hmac-sha1'

    # The url that should be used to handle subscription handshakes.
    attr_reader :callback_url

    # The url of the feed one wishes to subscribe to.
    attr_reader :topic_url

    # The hub this subscription is made with.
    attr_reader :hub

    # Creates a representation of a subscription.
    #
    # options:
    #   :callback_url => The url that should be used to handle subscription
    #                    handshakes.
    #   :topic_url    => The url of the feed one wishes to subscribe to.
    #   :secret       => A secret that will be passed to the callback to better
    #                    verify that communication is not replayed. Default:
    #                    A secure random hex.
    #   :hubs         => A list of hubs to negotiate the subscription with.
    #                    Default: attempts to discover the hubs when it
    #                    subscribes for the first time.
    #   :hub          => The hub we have a subscription with already.
    def initialize(options = {})
      @tokens = []

      secret = options[:secret] || SecureRandom.hex(32)
      @secret = secret.to_s

      @callback_url = options[:callback_url]
      @topic_url    = options[:topic_url]
      @tokens << options[:token] if options[:token]

      @hubs = options[:hubs] || []

      @hub  = options[:hub]
    end

    # Actively searches for hubs by talking to publisher directly
    def discover_hubs_for_topic
      @hubs = Lotus.feed_from_url(self.topic_url).hubs
    end

    # Subscribe to the topic through the given hub.
    def subscribe
      return unless self.hub.nil?

      # Discover hubs if none exist
      @hubs = discover_hubs_for_topic(self.topic_url) if self.hubs.empty?
      @hub = self.hubs.first
      change_subscription(:subscribe, token)

      # TODO: Check response, if failed, try a different hub
    end

    # Unsubscribe to the topic.
    def unsubscribe
      return if self.hub.nil?

      change_subscription(:unsubscribe)
    end

    # Change our subscription to this topic at a hub.
    # mode:    Either :subscribe or :unsubscribe
    # hub_url: The url of the hub to negotiate with
    # token:   A token to verify the response from the hub.
    def change_subscription(mode)
      token ||= SecureRandom.hex(32)
      @tokens << token.to_s

      # TODO: Set up HTTPS foo
      res = Net::HTTP.post_form(URI.parse(self.hub),
                                {
                                  'hub.mode' => mode.to_s,
                                  'hub.callback' => @callback_url,
                                  'hub.verify' => 'async',
                                  'hub.verify_token' => token,
                                  'hub.lease_seconds' => '',
                                  'hub.secret' => @secret,
                                  'hub.topic' => @topic_url
                                })
    end

    # Verify that a subscription response is valid.
    def verify_subscription(token)
      # Is there a token?
      result = @tokens.include?(token)

      # Ensure we cannot reuse the token
      @tokens.delete(token)

      result
    end

    # Determines if the given body matches the signature.
    def verify_content(body, signature)
      hmac = HMAC::SHA1.hexdigest(@secret, body)
      check = "sha1=" + hmac
      check == signature
    end

    # Gives the content of a challenge response given the challenge
    # body.
    def challenge_response(challenge_code)
      {
        :body => challenge_code,
        :status => 200
      }
    end
  end
end

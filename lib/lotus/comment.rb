module Lotus
  class Comment
    include Lotus::Object

    # Holds a collection of Lotus::Activity's that this comment is in reply to.
    attr_reader :in_reply_to

    # Create a new Comment activity object.
    #
    # options:
    #   :content      => The body of the comment in HTML.
    #   :author       => A Lotus::Person that created the object.
    #   :display_name => A natural-language, human-readable and plain-text name
    #                    for the comment.
    #   :summary      => Natural-language summarization of the comment.
    #   :url          => The canonical url of this comment.
    #   :uid          => The unique id that identifies this comment.
    #   :image        =>
    #   :published    => The Time when this comment was originally published.
    #   :updated      => The Time when this comment was last modified.
    def initialize(options = {})
      @in_reply_to  = options[:in_reply_to] || []

      super options
    end

    # Returns a Hash representing this comment.
    def to_hash
      {
        :in_reply_to  => @in_reply_to
      }.merge(super)
    end

    # Returns a Hash representing this comment with JSON ActivityStreams
    # conventions.
    def to_json_hash
      {
        :objectType   => "comment",
        :in_reply_to  => @in_reply_to
      }.merge(super)
    end
  end
end

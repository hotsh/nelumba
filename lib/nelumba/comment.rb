module Nelumba
  class Comment
    include Nelumba::Object

    # Create a new Comment activity object.
    #
    # options:
    #   :content      => The body of the comment in HTML.
    #   :author       => A Nelumba::Person that created the object.
    #   :display_name => A natural-language, human-readable and plain-text name
    #                    for the comment.
    #   :summary      => Natural-language summarization of the comment.
    #   :url          => The canonical url of this comment.
    #   :uid          => The unique id that identifies this comment.
    #   :image        =>
    #   :published    => The Time when this comment was originally published.
    #   :updated      => The Time when this comment was last modified.
    def initialize(options = {}, &blk)
      init(options, &blk)
    end

    def init(options = {}, &blk)
      options ||= {}
      options[:type] = :comment

      super options
    end
  end
end

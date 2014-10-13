module Nelumba
  class Article
    include Nelumba::Object

    # Create a new article.
    #
    # options:
    #   :title        => The title of the article. Defaults: "Untitled"
    #   :text         => The content of the article. Defaults: ""
    #   :html         => The content of the article as html.
    #   :author       => An Person that wrote the article.
    #   :url          => Permanent location for an html representation of the
    #                    article.
    #   :published    => When the article was originally published.
    #   :updated      => When the article was last updated.
    #   :uid          => The unique id that identifies this article.
    def initialize(options = {}, &blk)
      options ||= {}
      options[:type] = :article
      init(options, &blk)
    end
  end
end

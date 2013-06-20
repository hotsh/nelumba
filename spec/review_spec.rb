require_relative 'helper'
require_relative '../lib/lotus/review.rb'

describe Lotus::Review do
  describe "#initialize" do
    it "should store an author" do
      author = mock('author')
      Lotus::Review.new(:author => author).author.must_equal author
    end

    it "should store content" do
      Lotus::Review.new(:content => "txt").content.must_equal "txt"
    end

    it "should store rating" do
      Lotus::Review.new(:rating => "txt").rating.must_equal "txt"
    end

    it "should store the published date" do
      time = mock('date')
      Lotus::Review.new(:published => time).published.must_equal time
    end

    it "should store the updated date" do
      time = mock('date')
      Lotus::Review.new(:updated => time).updated.must_equal time
    end

    it "should store a display name" do
      Lotus::Review.new(:display_name => "url")
                        .display_name.must_equal "url"
    end

    it "should store a summary" do
      Lotus::Review.new(:summary => "url").summary.must_equal "url"
    end

    it "should store a url" do
      Lotus::Review.new(:url => "url").url.must_equal "url"
    end

    it "should store an id" do
      Lotus::Review.new(:uid => "id").uid.must_equal "id"
    end
  end

  describe "#to_hash" do
    it "should contain the content" do
      Lotus::Review.new(:content => "Hello")
                        .to_hash[:content].must_equal "Hello"
    end

    it "should contain the author" do
      author = mock('Lotus::Author')
      Lotus::Review.new(:author => author).to_hash[:author].must_equal author
    end

    it "should contain the rating" do
      Lotus::Review.new(:rating => "Hello").to_hash[:rating].must_equal "Hello"
    end

    it "should contain the uid" do
      Lotus::Review.new(:uid => "Hello").to_hash[:uid].must_equal "Hello"
    end

    it "should contain the url" do
      Lotus::Review.new(:url => "Hello").to_hash[:url].must_equal "Hello"
    end

    it "should contain the summary" do
      Lotus::Review.new(:summary=> "Hello")
                 .to_hash[:summary].must_equal "Hello"
    end

    it "should contain the display name" do
      Lotus::Review.new(:display_name => "Hello")
                 .to_hash[:display_name].must_equal "Hello"
    end

    it "should contain the published date" do
      date = mock('Time')
      Lotus::Review.new(:published => date).to_hash[:published].must_equal date
    end

    it "should contain the updated date" do
      date = mock('Time')
      Lotus::Review.new(:updated => date).to_hash[:updated].must_equal date
    end
  end

  describe "#to_json" do
    before do
      author = Lotus::Author.new :display_name => "wilkie"
      @note = Lotus::Review.new :content      => "Hello",
                                :author       => author,
                                :rating       => 123,
                                :uid          => "id",
                                :url          => "url",
                                :title        => "title",
                                :summary      => "foo",
                                :display_name => "meh",
                                :published    => Time.now,
                                :updated      => Time.now

      @json = @note.to_json
      @data = JSON.parse(@json)
    end

    it "should contain the embedded json for the author" do
      @data["author"].must_equal JSON.parse(@note.author.to_json)
    end

    it "should contain a 'review' objectType" do
      @data["objectType"].must_equal "review"
    end

    it "should contain the id" do
      @data["id"].must_equal @note.uid
    end

    it "should contain the rating" do
      @data["rating"].must_equal @note.rating
    end

    it "should contain the content" do
      @data["content"].must_equal @note.content
    end

    it "should contain the url" do
      @data["url"].must_equal @note.url
    end

    it "should contain the summary" do
      @data["summary"].must_equal @note.summary
    end

    it "should contain the display name" do
      @data["displayName"].must_equal @note.display_name
    end

    it "should contain the published date as rfc3339" do
      @data["published"].must_equal @note.published.to_date.rfc3339 + 'Z'
    end

    it "should contain the updated date as rfc3339" do
      @data["updated"].must_equal @note.updated.to_date.rfc3339 + 'Z'
    end
  end
end

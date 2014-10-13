require_relative 'helper'
require_relative '../lib/nelumba/bookmark.rb'

describe Nelumba::Bookmark do
  describe "#initialize" do
    it "should store an author" do
      author = mock('author')
      Nelumba::Bookmark.new(:author => author).author.must_equal author
    end

    it "should store the target url" do
      Nelumba::Bookmark.new(:target_url => "txt").target_url.must_equal "txt"
    end

    it "should store content" do
      Nelumba::Bookmark.new(:content => "txt").content.must_equal "txt"
    end

    it "should store the published date" do
      time = mock('date')
      Nelumba::Bookmark.new(:published => time).published.must_equal time
    end

    it "should store the updated date" do
      time = mock('date')
      Nelumba::Bookmark.new(:updated => time).updated.must_equal time
    end

    it "should store a display name" do
      Nelumba::Bookmark.new(:display_name => "url")
                       .display_name.must_equal "url"
    end

    it "should store a summary" do
      Nelumba::Bookmark.new(:summary => "url").summary.must_equal "url"
    end

    it "should store a url" do
      Nelumba::Bookmark.new(:url => "url").url.must_equal "url"
    end

    it "should store an id" do
      Nelumba::Bookmark.new(:uid => "id").uid.must_equal "id"
    end
  end

  describe "#to_hash" do
    it "should contain the content" do
      Nelumba::Bookmark.new(:content => "Hello")
                       .to_hash[:content].must_equal "Hello"
    end

    it "should contain the author" do
      author = mock('Nelumba::Person')
      Nelumba::Bookmark.new(:author => author).to_hash[:author].must_equal author
    end

    it "should contain the uid" do
      Nelumba::Bookmark.new(:uid => "Hello").to_hash[:uid].must_equal "Hello"
    end

    it "should contain the target_url" do
      Nelumba::Bookmark.new(:target_url => "Hello")
                       .to_hash[:target_url].must_equal "Hello"
    end

    it "should contain the url" do
      Nelumba::Bookmark.new(:url => "Hello").to_hash[:url].must_equal "Hello"
    end

    it "should contain the summary" do
      Nelumba::Bookmark.new(:summary=> "Hello")
                       .to_hash[:summary].must_equal "Hello"
    end

    it "should contain the display name" do
      Nelumba::Bookmark.new(:display_name => "Hello")
                       .to_hash[:display_name].must_equal "Hello"
    end

    it "should contain the published date" do
      date = mock('Time')
      Nelumba::Bookmark.new(:published => date).to_hash[:published].must_equal date
    end

    it "should contain the updated date" do
      date = mock('Time')
      Nelumba::Bookmark.new(:updated => date).to_hash[:updated].must_equal date
    end
  end

  describe "#to_json" do
    before do
      author = Nelumba::Person.new  :display_name => "wilkie"
      @note = Nelumba::Bookmark.new :content      => "Hello",
                                    :author       => author,
                                    :uid          => "id",
                                    :target_url   => "target",
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
      @data["authors"].first.must_equal JSON.parse(@note.authors.first.to_json)
    end

    it "should contain a 'bookmark' objectType" do
      @data["objectType"].must_equal "bookmark"
    end

    it "should contain the id" do
      @data["id"].must_equal @note.uid
    end

    it "should contain the target url" do
      @data["targetUrl"].must_equal @note.target_url
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
      @data["published"].must_equal @note.published.utc.iso8601
    end

    it "should contain the updated date as rfc3339" do
      @data["updated"].must_equal @note.updated.utc.iso8601
    end
  end
end

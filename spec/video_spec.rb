require_relative 'helper'
require_relative '../lib/nelumba/video.rb'

describe Nelumba::Video do
  describe "#initialize" do
    it "should store an author" do
      author = mock('author')
      Nelumba::Video.new(:author => author).authors.first.must_equal author
    end

    it "should store multiple authors" do
      author = mock('author')
      author2 = mock('author')
      Nelumba::Video.new(:authors => [author, author2]).authors.must_equal [author, author2]
    end

    it "should store the stream" do
      Nelumba::Video.new(:stream => "txt").stream.must_equal "txt"
    end

    it "should store the embed code" do
      Nelumba::Video.new(:embed_code => "txt").embed_code.must_equal "txt"
    end

    it "should store content" do
      Nelumba::Video.new(:content => "txt").content.must_equal "txt"
    end

    it "should store the published date" do
      time = mock('date')
      Nelumba::Video.new(:published => time).published.must_equal time
    end

    it "should store the updated date" do
      time = mock('date')
      Nelumba::Video.new(:updated => time).updated.must_equal time
    end

    it "should store a display name" do
      Nelumba::Video.new(:display_name => "url")
                        .display_name.must_equal "url"
    end

    it "should store a summary" do
      Nelumba::Video.new(:summary => "url").summary.must_equal "url"
    end

    it "should store a url" do
      Nelumba::Video.new(:url => "url").url.must_equal "url"
    end

    it "should store an id" do
      Nelumba::Video.new(:uid => "id").uid.must_equal "id"
    end
  end

  describe "#to_hash" do
    it "should contain the stream" do
      Nelumba::Video.new(:stream => "txt")
                  .to_hash[:stream].must_equal "txt"
    end

    it "should contain the embed code" do
      Nelumba::Video.new(:embed_code => "txt")
                  .to_hash[:embed_code].must_equal "txt"
    end

    it "should contain the content" do
      Nelumba::Video.new(:content => "Hello")
                        .to_hash[:content].must_equal "Hello"
    end

    it "should contain the author" do
      author = mock('Nelumba::Person')
      Nelumba::Video.new(:author => author).to_hash[:authors].first.must_equal author
    end

    it "should contain all authors" do
      author = mock('Nelumba::Person')
      author2 = mock('Nelumba::Person')
      Nelumba::Video.new(:authors => [author, author2]).to_hash[:authors].must_equal [author, author2]
    end

    it "should contain the uid" do
      Nelumba::Video.new(:uid => "Hello").to_hash[:uid].must_equal "Hello"
    end

    it "should contain the url" do
      Nelumba::Video.new(:url => "Hello").to_hash[:url].must_equal "Hello"
    end

    it "should contain the summary" do
      Nelumba::Video.new(:summary=> "Hello")
                 .to_hash[:summary].must_equal "Hello"
    end

    it "should contain the display name" do
      Nelumba::Video.new(:display_name => "Hello")
                 .to_hash[:display_name].must_equal "Hello"
    end

    it "should contain the published date" do
      date = mock('Time')
      Nelumba::Video.new(:published => date).to_hash[:published].must_equal date
    end

    it "should contain the updated date" do
      date = mock('Time')
      Nelumba::Video.new(:updated => date).to_hash[:updated].must_equal date
    end
  end

  describe "#to_json" do
    before do
      author = Nelumba::Person.new :display_name => "wilkie"
      @note = Nelumba::Video.new :content      => "Hello",
                               :author       => author,
                               :embed_code   => "code",
                               :stream       => "foo",
                               :summary      => "foo",
                               :display_name => "meh",
                               :uid          => "id",
                               :url          => "url",
                               :title        => "title",
                               :published    => Time.now,
                               :updated      => Time.now

      @json = @note.to_json
      @data = JSON.parse(@json)
    end

    it "should contain the embedded json for the author" do
      @data["authors"].first.must_equal JSON.parse(@note.authors.first.to_json)
    end

    it "should contain the stream" do
      @data["stream"].must_equal @note.stream
    end

    it "should contain the embed code" do
      @data["embedCode"].must_equal @note.embed_code
    end

    it "should contain a 'video' objectType" do
      @data["objectType"].must_equal "video"
    end

    it "should contain the id" do
      @data["id"].must_equal @note.uid
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

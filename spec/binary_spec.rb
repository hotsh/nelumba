require_relative 'helper'
require_relative '../lib/nelumba/binary.rb'

describe Nelumba::Binary do
  describe "#initialize" do
    it "should store an author" do
      author = mock('author')
      Nelumba::Binary.new(:author => author).authors.first.must_equal author
    end

    it "should store multiple authors" do
      author  = mock('author')
      author2 = mock('author')
      Nelumba::Binary.new(:authors => [author, author2]).authors.must_equal [author, author2]
    end

    it "should store content" do
      Nelumba::Binary.new(:content => "txt").content.must_equal "txt"
    end

    it "should store the data" do
      Nelumba::Binary.new(:data => "txt").data.must_equal "txt"
    end

    it "should store the compression" do
      Nelumba::Binary.new(:compression => "txt").compression.must_equal "txt"
    end

    it "should store the md5" do
      Nelumba::Binary.new(:md5 => "txt").md5.must_equal "txt"
    end

    it "should store the file url" do
      Nelumba::Binary.new(:file_url => "txt").file_url.must_equal "txt"
    end

    it "should store the mime_type" do
      Nelumba::Binary.new(:mime_type => "txt").mime_type.must_equal "txt"
    end

    it "should store the length" do
      Nelumba::Binary.new(:length => "txt").length.must_equal "txt"
    end

    it "should store the published date" do
      time = mock('date')
      Nelumba::Binary.new(:published => time).published.must_equal time
    end

    it "should store the updated date" do
      time = mock('date')
      Nelumba::Binary.new(:updated => time).updated.must_equal time
    end

    it "should store a display name" do
      Nelumba::Binary.new(:display_name => "url")
                        .display_name.must_equal "url"
    end

    it "should store a summary" do
      Nelumba::Binary.new(:summary => "url").summary.must_equal "url"
    end

    it "should store a url" do
      Nelumba::Binary.new(:url => "url").url.must_equal "url"
    end

    it "should store an id" do
      Nelumba::Binary.new(:uid => "id").uid.must_equal "id"
    end
  end

  describe "#to_hash" do
    it "should contain the content" do
      Nelumba::Binary.new(:content => "Hello")
                        .to_hash[:content].must_equal "Hello"
    end

    it "should contain the data" do
      Nelumba::Binary.new(:data => "txt")
                   .to_hash[:data].must_equal "txt"
    end

    it "should contain the compression" do
      Nelumba::Binary.new(:compression => "txt")
                   .to_hash[:compression].must_equal "txt"
    end

    it "should contain the md5" do
      Nelumba::Binary.new(:md5 => "txt")
                   .to_hash[:md5].must_equal "txt"
    end

    it "should contain the file url" do
      Nelumba::Binary.new(:file_url => "txt")
                   .to_hash[:file_url].must_equal "txt"
    end

    it "should contain the mime_type" do
      Nelumba::Binary.new(:mime_type => "txt")
                   .to_hash[:mime_type].must_equal "txt"
    end

    it "should contain the length" do
      Nelumba::Binary.new(:length => "txt")
                   .to_hash[:length].must_equal "txt"
    end

    it "should contain the author" do
      author = mock('Nelumba::Person')
      Nelumba::Binary.new(:author => author).to_hash[:authors].first.must_equal author
    end

    it "should contain all authors" do
      author  = mock('Nelumba::Person')
      author2 = mock('Nelumba::Person')
      Nelumba::Binary.new(:author => [author, author2]).to_hash[:authors].must_equal [author, author2]
    end

    it "should contain the uid" do
      Nelumba::Binary.new(:uid => "Hello").to_hash[:uid].must_equal "Hello"
    end

    it "should contain the url" do
      Nelumba::Binary.new(:url => "Hello").to_hash[:url].must_equal "Hello"
    end

    it "should contain the summary" do
      Nelumba::Binary.new(:summary=> "Hello")
                 .to_hash[:summary].must_equal "Hello"
    end

    it "should contain the display name" do
      Nelumba::Binary.new(:display_name => "Hello")
                 .to_hash[:display_name].must_equal "Hello"
    end

    it "should contain the published date" do
      date = mock('Time')
      Nelumba::Binary.new(:published => date).to_hash[:published].must_equal date
    end

    it "should contain the updated date" do
      date = mock('Time')
      Nelumba::Binary.new(:updated => date).to_hash[:updated].must_equal date
    end
  end

  describe "#to_json" do
    before do
      author = Nelumba::Person.new :display_name => "wilkie"
      @note = Nelumba::Binary.new  :content      => "Hello",
                                   :author       => author,
                                   :data         => "data",
                                   :length       => 125,
                                   :compression  => "foo",
                                   :md5          => "hash",
                                   :file_url     => "file url",
                                   :mime_type    => "image/png",
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

    it "should contain the data" do
      @data["data"].must_equal @note.data
    end

    it "should contain the compression" do
      @data["compression"].must_equal @note.compression
    end

    it "should contain the md5" do
      @data["md5"].must_equal @note.md5
    end

    it "should contain the file_url" do
      @data["fileUrl"].must_equal @note.file_url
    end

    it "should contain the mime_type" do
      @data["mimeType"].must_equal @note.mime_type
    end

    it "should contain the length" do
      @data["length"].must_equal @note.length
    end

    it "should contain a 'binary' objectType" do
      @data["objectType"].must_equal "binary"
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

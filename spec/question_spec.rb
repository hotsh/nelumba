require_relative 'helper'
require_relative '../lib/nelumba/question.rb'

describe Nelumba::Question do
  describe "#initialize" do
    it "should store an author" do
      author = mock('author')
      Nelumba::Question.new(:author => author).authors.first.must_equal author
    end

    it "should store multiple authors" do
      author  = mock('author')
      author2 = mock('author')
      Nelumba::Question.new(:authors => [author, author2]).authors.must_equal [author, author2]
    end

    it "should store content" do
      Nelumba::Question.new(:content => "txt").content.must_equal "txt"
    end

    it "should store the options array" do
      Nelumba::Question.new(:options => ["a","b"]).options.must_equal ["a","b"]
    end

    it "should store the published date" do
      time = mock('date')
      Nelumba::Question.new(:published => time).published.must_equal time
    end

    it "should store the updated date" do
      time = mock('date')
      Nelumba::Question.new(:updated => time).updated.must_equal time
    end

    it "should store a display name" do
      Nelumba::Question.new(:display_name => "url")
                       .display_name.must_equal "url"
    end

    it "should store a summary" do
      Nelumba::Question.new(:summary => "url").summary.must_equal "url"
    end

    it "should store a url" do
      Nelumba::Question.new(:url => "url").url.must_equal "url"
    end

    it "should store an id" do
      Nelumba::Question.new(:uid => "id").uid.must_equal "id"
    end

    it "should default options to empty array" do
      Nelumba::Question.new.options.must_equal []
    end
  end

  describe "#to_hash" do
    it "should contain the content" do
      Nelumba::Question.new(:content => "Hello")
                       .to_hash[:content].must_equal "Hello"
    end

    it "should contain the author" do
      author = mock('Nelumba::Person')
      Nelumba::Question.new(:author => author).to_hash[:authors].first.must_equal author
    end

    it "should contain all authors" do
      author  = mock('Nelumba::Person')
      author2 = mock('Nelumba::Person')
      Nelumba::Question.new(:authors => [author, author2]).to_hash[:authors].must_equal [author, author2]
    end

    it "should contain options" do
      Nelumba::Question.new(:options => ["a","b"])
                       .to_hash[:options].must_equal ["a","b"]
    end

    it "should contain the uid" do
      Nelumba::Question.new(:uid => "Hello").to_hash[:uid].must_equal "Hello"
    end

    it "should contain the url" do
      Nelumba::Question.new(:url => "Hello").to_hash[:url].must_equal "Hello"
    end

    it "should contain the summary" do
      Nelumba::Question.new(:summary=> "Hello")
                       .to_hash[:summary].must_equal "Hello"
    end

    it "should contain the display name" do
      Nelumba::Question.new(:display_name => "Hello")
                       .to_hash[:display_name].must_equal "Hello"
    end

    it "should contain the published date" do
      date = mock('Time')
      Nelumba::Question.new(:published => date)
                       .to_hash[:published].must_equal date
    end

    it "should contain the updated date" do
      date = mock('Time')
      Nelumba::Question.new(:updated => date)
                       .to_hash[:updated].must_equal date
    end
  end

  describe "#to_json" do
    before do
      author = Nelumba::Person.new  :display_name => "wilkie"
      @note = Nelumba::Question.new :content      => "Hello",
                                    :author       => author,
                                    :options      => ["foo"],
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
      @data["authors"].first.must_equal JSON.parse(@note.authors.first.to_json)
    end

    it "should contain a 'question' objectType" do
      @data["objectType"].must_equal "question"
    end

    it "should contain the options array" do
      @data["options"].must_equal JSON.parse(@note.options.to_json)
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

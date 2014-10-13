require_relative 'helper'
require_relative '../lib/nelumba/note.rb'

describe Nelumba::Note do
  describe "#initialize" do
    it "should store a title" do
      Nelumba::Note.new(:title => "My Title").title.must_equal "My Title"
    end

    it "should store an author" do
      author = mock('author')
      Nelumba::Note.new(:author => author).authors.first.must_equal author
    end

    it "should store multiple authors" do
      author  = mock('author')
      author2 = mock('author')
      Nelumba::Note.new(:authors => [author, author2]).authors.must_equal [author, author2]
    end

    it "should store text" do
      Nelumba::Note.new(:text => "Hello").text.must_equal "Hello"
    end

    it "should store html" do
      Nelumba::Note.new(:html => "txt").html.must_equal "txt"
    end

    it "should store the published date" do
      time = mock('date')
      Nelumba::Note.new(:published => time).published.must_equal time
    end

    it "should store the updated date" do
      time = mock('date')
      Nelumba::Note.new(:updated => time).updated.must_equal time
    end

    it "should store a summary" do
      Nelumba::Note.new(:summary => "url").summary.must_equal "url"
    end

    it "should store a display name" do
      Nelumba::Note.new(:display_name => "url")
                   .display_name.must_equal "url"
    end

    it "should store a url" do
      Nelumba::Note.new(:url => "url").url.must_equal "url"
    end

    it "should store an id" do
      Nelumba::Note.new(:uid => "id").uid.must_equal "id"
    end

    it "should default the text to '' if not given" do
      Nelumba::Note.new.text.must_equal ''
    end

    it "should default the title to 'Untitled' if not given" do
      Nelumba::Note.new.title.must_equal "Untitled"
    end
  end

  describe "#to_hash" do
    it "should contain the text" do
      Nelumba::Note.new(:text => "Hello").to_hash[:text].must_equal "Hello"
    end

    it "should contain the html" do
      Nelumba::Note.new(:html => "Hello").to_hash[:html].must_equal "Hello"
    end

    it "should contain the title" do
      Nelumba::Note.new(:title => "Hello").to_hash[:title].must_equal "Hello"
    end

    it "should contain the author" do
      author = mock('Nelumba::Person')
      Nelumba::Note.new(:author => author).to_hash[:authors].first.must_equal author
    end

    it "should contain all authors" do
      author  = mock('Nelumba::Person')
      author2 = mock('Nelumba::Person')
      Nelumba::Note.new(:authors => [author, author2]).to_hash[:authors].must_equal [author, author2]
    end

    it "should contain the uid" do
      Nelumba::Note.new(:uid => "Hello").to_hash[:uid].must_equal "Hello"
    end

    it "should contain the url" do
      Nelumba::Note.new(:url => "Hello").to_hash[:url].must_equal "Hello"
    end

    it "should contain the summary" do
      Nelumba::Note.new(:summary => "Hello")
                   .to_hash[:summary].must_equal "Hello"
    end

    it "should contain the display name" do
      Nelumba::Note.new(:display_name => "Hello")
                   .to_hash[:display_name].must_equal "Hello"
    end

    it "should contain the published date" do
      date = mock('Time')
      Nelumba::Note.new(:published => date).to_hash[:published].must_equal date
    end

    it "should contain the updated date" do
      date = mock('Time')
      Nelumba::Note.new(:updated => date).to_hash[:updated].must_equal date
    end
  end

  describe "#to_json" do
    before do
      author = Nelumba::Person.new :display_name => "wilkie"
      @note = Nelumba::Note.new    :text         => "Hello",
                                   :author       => author,
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

    it "should contain a 'note' objectType" do
      @data["objectType"].must_equal "note"
    end

    it "should contain the id" do
      @data["id"].must_equal @note.uid
    end

    it "should contain the content as the html" do
      @data["content"].must_equal @note.html
    end

    it "should contain the title" do
      @data["title"].must_equal @note.title
    end

    it "should contain the url" do
      @data["url"].must_equal @note.url
    end

    it "should contain the summary" do
      @data["summary"].must_equal @note.summary
    end

    it "should contain the display_name" do
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

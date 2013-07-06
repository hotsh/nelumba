require_relative 'helper'
require_relative '../lib/lotus/note.rb'

describe Lotus::Note do
  describe "#initialize" do
    it "should store a title" do
      Lotus::Note.new(:title => "My Title").title.must_equal "My Title"
    end

    it "should store an author" do
      author = mock('author')
      Lotus::Note.new(:author => author).author.must_equal author
    end

    it "should store text" do
      Lotus::Note.new(:text => "Hello").text.must_equal "Hello"
    end

    it "should store html" do
      Lotus::Note.new(:html => "txt").html.must_equal "txt"
    end

    it "should store the published date" do
      time = mock('date')
      Lotus::Note.new(:published => time).published.must_equal time
    end

    it "should store the updated date" do
      time = mock('date')
      Lotus::Note.new(:updated => time).updated.must_equal time
    end

    it "should store a summary" do
      Lotus::Note.new(:summary => "url").summary.must_equal "url"
    end

    it "should store a display name" do
      Lotus::Note.new(:display_name => "url")
                 .display_name.must_equal "url"
    end

    it "should store a url" do
      Lotus::Note.new(:url => "url").url.must_equal "url"
    end

    it "should store an id" do
      Lotus::Note.new(:uid => "id").uid.must_equal "id"
    end

    it "should default the text to '' if not given" do
      Lotus::Note.new.text.must_equal ''
    end

    it "should default the title to 'Untitled' if not given" do
      Lotus::Note.new.title.must_equal "Untitled"
    end
  end

  describe "#to_hash" do
    it "should contain the text" do
      Lotus::Note.new(:text => "Hello").to_hash[:text].must_equal "Hello"
    end

    it "should contain the html" do
      Lotus::Note.new(:html => "Hello").to_hash[:html].must_equal "Hello"
    end

    it "should contain the title" do
      Lotus::Note.new(:title => "Hello").to_hash[:title].must_equal "Hello"
    end

    it "should contain the author" do
      author = mock('Lotus::Person')
      Lotus::Note.new(:author => author).to_hash[:author].must_equal author
    end

    it "should contain the uid" do
      Lotus::Note.new(:uid => "Hello").to_hash[:uid].must_equal "Hello"
    end

    it "should contain the url" do
      Lotus::Note.new(:url => "Hello").to_hash[:url].must_equal "Hello"
    end

    it "should contain the summary" do
      Lotus::Note.new(:summary => "Hello")
                 .to_hash[:summary].must_equal "Hello"
    end

    it "should contain the display name" do
      Lotus::Note.new(:display_name => "Hello")
                 .to_hash[:display_name].must_equal "Hello"
    end

    it "should contain the published date" do
      date = mock('Time')
      Lotus::Note.new(:published => date).to_hash[:published].must_equal date
    end

    it "should contain the updated date" do
      date = mock('Time')
      Lotus::Note.new(:updated => date).to_hash[:updated].must_equal date
    end
  end

  describe "#to_json" do
    before do
      author = Lotus::Person.new :display_name => "wilkie"
      @note = Lotus::Note.new :text         => "Hello",
                              :author       => author,
                              :uid          => "id",
                              :url          => "url",
                              :title        => "title",
                              :summary      => "foo",
                              :display_name => "meh",
                              :published   => Time.now,
                              :updated     => Time.now

      @json = @note.to_json
      @data = JSON.parse(@json)
    end

    it "should contain the embedded json for the author" do
      @data["author"].must_equal JSON.parse(@note.author.to_json)
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
      @data["published"].must_equal @note.published.to_date.rfc3339 + 'Z'
    end

    it "should contain the updated date as rfc3339" do
      @data["updated"].must_equal @note.updated.to_date.rfc3339 + 'Z'
    end
  end
end

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

    it "should store content" do
      Lotus::Note.new(:content => "Hello").content.must_equal "Hello"
    end

    it "should store the content type" do
      Lotus::Note.new(:content_type => "txt").content_type.must_equal "txt"
    end

    it "should store the published date" do
      time = mock('date')
      Lotus::Note.new(:published => time).published.must_equal time
    end

    it "should store the updated date" do
      time = mock('date')
      Lotus::Note.new(:updated => time).updated.must_equal time
    end

    it "should store a url" do
      Lotus::Note.new(:url => "url").url.must_equal "url"
    end

    it "should store an id" do
      Lotus::Note.new(:uid => "id").uid.must_equal "id"
    end

    it "should default the content to '' if not given" do
      Lotus::Note.new.content.must_equal ''
    end

    it "should default the title to 'Untitled' if not given" do
      Lotus::Note.new.title.must_equal "Untitled"
    end
  end
end

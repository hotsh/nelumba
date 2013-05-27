require_relative 'helper'
require_relative '../lib/lotus/activity.rb'

describe Lotus::Activity do
  describe "#initialize" do
    it "should store an object" do
      Lotus::Activity.new(:object => "object").object.must_equal "object"
    end

    it "should store an type" do
      Lotus::Activity.new(:type => :audio).type.must_equal :audio
    end

    it "should store a verb" do
      Lotus::Activity.new(:verb => :follow).verb.must_equal :follow
    end

    it "should store a target" do
      Lotus::Activity.new(:target => "target").target.must_equal "target"
    end

    it "should store a title" do
      Lotus::Activity.new(:title => "My Title").title.must_equal "My Title"
    end

    it "should store an actor" do
      actor = mock('author')
      Lotus::Activity.new(:actor => actor).actor.must_equal actor
    end

    it "should store content" do
      Lotus::Activity.new(:content => "Hello").content.must_equal "Hello"
    end

    it "should store the content type" do
      Lotus::Activity.new(:content_type => "txt").content_type.must_equal "txt"
    end

    it "should store the published date" do
      time = mock('date')
      Lotus::Activity.new(:published => time).published.must_equal time
    end

    it "should store the updated date" do
      time = mock('date')
      Lotus::Activity.new(:updated => time).updated.must_equal time
    end

    it "should store a source feed" do
      feed = mock('feed')
      Lotus::Activity.new(:source => feed).source.must_equal feed
    end

    it "should store a url" do
      Lotus::Activity.new(:url => "url").url.must_equal "url"
    end

    it "should store an id" do
      Lotus::Activity.new(:id => "id").id.must_equal "id"
    end

    it "should store an array of threads" do
      thread = mock('entry')
      Lotus::Activity.new(:in_reply_to => [thread]).in_reply_to.must_equal [thread]
    end

    it "should store an array of threads when only given one entry" do
      thread = mock('entry')
      Lotus::Activity.new(:in_reply_to => thread).in_reply_to.must_equal [thread]
    end

    it "should store an empty array of threads by default" do
      Lotus::Activity.new.in_reply_to.must_equal []
    end

    it "should store an array of replies" do
      thread = mock('entry')
      Lotus::Activity.new(:replies => [thread]).replies.must_equal [thread]
    end

    it "should store an empty array of replies by default" do
      Lotus::Activity.new.replies.must_equal []
    end

    it "should store an array of shares" do
      thread = mock('entry')
      Lotus::Activity.new(:shares => [thread]).shares.must_equal [thread]
    end

    it "should store an empty array of shares by default" do
      Lotus::Activity.new.shares.must_equal []
    end

    it "should store an array of mentions" do
      thread = mock('entry')
      Lotus::Activity.new(:mentions => [thread]).mentions.must_equal [thread]
    end

    it "should store an empty array of mentions by default" do
      Lotus::Activity.new.mentions.must_equal []
    end

    it "should store an array of likes" do
      thread = mock('entry')
      Lotus::Activity.new(:likes => [thread]).likes.must_equal [thread]
    end

    it "should store an empty array of likes by default" do
      Lotus::Activity.new.likes.must_equal []
    end

    it "should default the content to '' if not given" do
      Lotus::Activity.new.content.must_equal ''
    end

    it "should default the title to 'Untitled' if not given" do
      Lotus::Activity.new.title.must_equal "Untitled"
    end
  end
end

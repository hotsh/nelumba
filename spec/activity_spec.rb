require_relative 'helper'
require_relative '../lib/nelumba/activity.rb'

describe Nelumba::Activity do
  describe "#initialize" do
    it "should store an object" do
      Nelumba::Activity.new(:object => "object").object.must_equal "object"
    end

    it "should store a type of 'activity'" do
      Nelumba::Activity.new.type.must_equal :activity
    end

    it "should store a verb" do
      Nelumba::Activity.new(:verb => :follow).verb.must_equal :follow
    end

    it "should store a target" do
      Nelumba::Activity.new(:target => "target").targets.first.must_equal "target"
    end

    it "should store multiple targets" do
      Nelumba::Activity.new(:targets => ["target", "target2"]).targets.must_equal ["target", "target2"]
    end

    it "should store an actor" do
      actor = mock('author')
      Nelumba::Activity.new(:actor => actor).actors.first.must_equal actor
    end

    it "should store multiple actors" do
      actor = mock('author')
      actor2 = mock('author')
      Nelumba::Activity.new(:actors => [actor, actor2]).actors.must_equal [actor, actor2]
    end

    it "should store the published date" do
      time = mock('date')
      Nelumba::Activity.new(:published => time).published.must_equal time
    end

    it "should store the updated date" do
      time = mock('date')
      Nelumba::Activity.new(:updated => time).updated.must_equal time
    end

    it "should store a source feed" do
      feed = mock('feed')
      Nelumba::Activity.new(:source => feed).source.must_equal feed
    end

    it "should store a url" do
      Nelumba::Activity.new(:url => "url").url.must_equal "url"
    end

    it "should store an id" do
      Nelumba::Activity.new(:uid => "id").uid.must_equal "id"
    end

    it "should store an array of threads" do
      thread = mock('entry')
      Nelumba::Activity.new(:in_reply_to => [thread]).in_reply_to.must_equal [thread]
    end

    it "should store an array of threads when only given one entry" do
      thread = mock('entry')
      Nelumba::Activity.new(:in_reply_to => thread).in_reply_to.must_equal [thread]
    end

    it "should store an empty array of threads by default" do
      Nelumba::Activity.new.in_reply_to.must_equal []
    end

    it "should store an array of replies" do
      thread = mock('entry')
      Nelumba::Activity.new(:replies => [thread]).replies.must_equal [thread]
    end

    it "should store an empty array of replies by default" do
      Nelumba::Activity.new.replies.must_equal []
    end

    it "should store an array of shares" do
      thread = mock('entry')
      Nelumba::Activity.new(:shares => [thread]).shares.must_equal [thread]
    end

    it "should store an empty array of shares by default" do
      Nelumba::Activity.new.shares.must_equal []
    end

    it "should store an array of mentions" do
      thread = mock('person')
      Nelumba::Activity.new(:mentions => [thread]).mentions.must_equal [thread]
    end

    it "should store an empty array of mentions by default" do
      Nelumba::Activity.new.mentions.must_equal []
    end

    it "should store an array of likes" do
      thread = mock('person')
      Nelumba::Activity.new(:likes => [thread]).likes.must_equal [thread]
    end

    it "should store an empty array of likes by default" do
      Nelumba::Activity.new.likes.must_equal []
    end

    it "should store an empty hash of interactions by default" do
      Nelumba::Activity.new.interactions.must_equal({})
    end
  end

  describe "#interaction_count" do
    it "should pull values out of interactions" do
      Nelumba::Activity.new(:interactions => {:share => {:count => 3}})
                     .interaction_count(:share).must_equal 3
    end

    it "should defautl a value of 0 when verb isn't found" do
      Nelumba::Activity.new(:interactions => {:share => {:count => 3}})
                     .interaction_count(:like).must_equal 0
    end
  end
end

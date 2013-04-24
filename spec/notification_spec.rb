require_relative 'helper'
require_relative '../lib/lotus/notification.rb'

describe Lotus::Notification do
  describe "from_xml" do
    it "should return nil if source is empty string" do
      Lotus::Notification.from_xml("").must_equal(nil)
    end

    it "should return nil if source is nil" do
      Lotus::Notification.from_xml(nil).must_equal(nil)
    end
  end

  describe "from_data" do
    it "should relegate for xml mime types" do
      Lotus::Notification.expects(:from_xml).times(5)
      Lotus::Notification.from_data("content", "xml")
      Lotus::Notification.from_data("content", "magic-envelope+xml")
      Lotus::Notification.from_data("content", "application/xml")
      Lotus::Notification.from_data("content", "application/text+xml")
      Lotus::Notification.from_data("content", "application/magic-envelope+xml")
    end

    it "should relegate for json mime types" do
      Lotus::Notification.expects(:from_json).times(5)
      Lotus::Notification.from_data("content", "json")
      Lotus::Notification.from_data("content", "magic-envelope+json")
      Lotus::Notification.from_data("content", "application/json")
      Lotus::Notification.from_data("content", "application/text+json")
      Lotus::Notification.from_data("content", "application/magic-envelope+json")
    end
  end

  describe "from_unfollow" do
    before do
      @user   = Lotus::Author.new(:name => "wilkie")
      @follow = Lotus::Author.new(:name => "wilkie")
      @salmon = Lotus::Notification.from_unfollow(@user, @follow)
    end

    it "should create a new Notification representing the given user author" do
      @salmon.activity.actor.must_equal @user
    end

    it "should create a new Notification representing the given user author" do
      @salmon.activity.object.must_equal @follow
    end
  end

  describe "from_follow" do
    before do
      @user   = Lotus::Author.new(:name => "wilkie")
      @follow = Lotus::Author.new(:name => "wilkie")
      @salmon = Lotus::Notification.from_follow(@user, @follow)
    end

    it "should create a new Notification representing the given user author" do
      @salmon.activity.actor.must_equal @user
    end

    it "should create a new Notification representing the given user author" do
      @salmon.activity.object.must_equal @follow
    end
  end

  describe "from_profile_update" do
    before do
      @user   = Lotus::Author.new(:name => "wilkie")
      @salmon = Lotus::Notification.from_profile_update(@user)
    end

    it "should create a new Notification representing the given user author" do
      @salmon.activity.actor.must_equal @user
    end
  end
end

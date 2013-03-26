require_relative 'helper'
require_relative '../lib/lotus/notification.rb'

describe Lotus::Notification do
  describe "Notification.from_xml" do
    it "should return nil if source is empty string" do
      Lotus::Notification.from_xml("").must_equal(nil)
    end
  end

  describe "Notification.from_unfollow" do
    before do
      @user   = Lotus::Author.new(:name => "wilkie")
      @follow = Lotus::Author.new(:name => "wilkie")
      @salmon = Lotus::Notification.from_unfollow(@user, @follow)
    end

    it "should create a new Notification representing the given user author" do
      @salmon.entry.actor.must_equal @user
    end

    it "should create a new Notification representing the given user author" do
      @salmon.entry.object.must_equal @follow
    end
  end

  describe "Notification.from_follow" do
    before do
      @user   = Lotus::Author.new(:name => "wilkie")
      @follow = Lotus::Author.new(:name => "wilkie")
      @salmon = Lotus::Notification.from_follow(@user, @follow)
    end

    it "should create a new Notification representing the given user author" do
      @salmon.entry.actor.must_equal @user
    end

    it "should create a new Notification representing the given user author" do
      @salmon.entry.object.must_equal @follow
    end
  end

  describe "Notification.from_profile_update" do
    before do
      @user   = Lotus::Author.new(:name => "wilkie")
      @salmon = Lotus::Notification.from_profile_update(@user)
    end

    it "should create a new Notification representing the given user author" do
      @salmon.entry.actor.must_equal @user
    end
  end
end

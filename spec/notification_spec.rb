require_relative 'helper'
require_relative '../lib/nelumba/notification.rb'

describe Nelumba::Notification do
  describe "from_xml" do
    it "should return nil if source is empty string" do
      Nelumba::Notification.from_xml("").must_equal(nil)
    end

    it "should return nil if source is nil" do
      Nelumba::Notification.from_xml(nil).must_equal(nil)
    end
  end

  describe "from_data" do
    it "should relegate for xml mime types" do
      Nelumba::Notification.expects(:from_xml).times(5)
      Nelumba::Notification.from_data("content", "xml")
      Nelumba::Notification.from_data("content", "magic-envelope+xml")
      Nelumba::Notification.from_data("content", "application/xml")
      Nelumba::Notification.from_data("content", "application/text+xml")
      Nelumba::Notification.from_data("content", "application/magic-envelope+xml")
    end

    it "should relegate for json mime types" do
      Nelumba::Notification.expects(:from_json).times(5)
      Nelumba::Notification.from_data("content", "json")
      Nelumba::Notification.from_data("content", "magic-envelope+json")
      Nelumba::Notification.from_data("content", "application/json")
      Nelumba::Notification.from_data("content", "application/text+json")
      Nelumba::Notification.from_data("content", "application/magic-envelope+json")
    end
  end

  describe "from_unfollow" do
    before do
      @user   = Nelumba::Person.new(:name => "wilkie")
      @follow = Nelumba::Person.new(:name => "wilkie")
      @salmon = Nelumba::Notification.from_unfollow(@user, @follow)
    end

    it "should create a new Notification representing the given user author" do
      @salmon.activity.actors.first.must_equal @user
    end

    it "should create a new Notification representing the given user author" do
      @salmon.activity.object.must_equal @follow
    end
  end

  describe "from_follow" do
    before do
      @user   = Nelumba::Person.new(:name => "wilkie")
      @follow = Nelumba::Person.new(:name => "wilkie")
      @salmon = Nelumba::Notification.from_follow(@user, @follow)
    end

    it "should create a new Notification representing the given user author" do
      @salmon.activity.actors.first.must_equal @user
    end

    it "should create a new Notification representing the given user author" do
      @salmon.activity.object.must_equal @follow
    end
  end

  describe "from_profile_update" do
    before do
      @user   = Nelumba::Person.new(:name => "wilkie")
      @salmon = Nelumba::Notification.from_profile_update(@user)
    end

    it "should create a new Notification representing the given user author" do
      @salmon.activity.actors.first.must_equal @user
    end
  end

  describe "account" do
    before do
      @user   = Nelumba::Person.new(:name => "wilkie", :url => "acct:wilkie@rstat.us")
      @follow = Nelumba::Person.new(:name => "wilkie")
      @salmon = Nelumba::Notification.from_follow(@user, @follow)
    end

    it "should provide the url of the actor when the url is an account" do
      @salmon.account.must_equal @salmon.activity.actors.first.url
    end
  end
end

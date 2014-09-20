require_relative 'helper'
require_relative '../lib/nelumba/event.rb'

describe Nelumba::Event do
  describe "#initialize" do
    it "should store an author" do
      author = mock('author')
      Nelumba::Event.new(:author => author).author.must_equal author
    end

    it "should store content" do
      Nelumba::Event.new(:content => "txt").content.must_equal "txt"
    end

    it "should store attending array" do
      Nelumba::Event.new(:attending => ["a","b"])
                  .attending.must_equal ["a","b"]
    end

    it "should store maybe_attending array" do
      Nelumba::Event.new(:maybe_attending => ["a","b"])
                  .maybe_attending.must_equal ["a","b"]
    end

    it "should store not_attending array" do
      Nelumba::Event.new(:not_attending => ["a","b"])
                  .not_attending.must_equal ["a","b"]
    end

    it "should store start time date" do
      time = mock('date')
      Nelumba::Event.new(:start_time => time).start_time.must_equal time
    end

    it "should store end time date" do
      time = mock('date')
      Nelumba::Event.new(:end_time => time).end_time.must_equal time
    end

    it "should store location" do
      Nelumba::Event.new(:location => "place").location.must_equal "place"
    end

    it "should store the published date" do
      time = mock('date')
      Nelumba::Event.new(:published => time).published.must_equal time
    end

    it "should store the updated date" do
      time = mock('date')
      Nelumba::Event.new(:updated => time).updated.must_equal time
    end

    it "should store a display name" do
      Nelumba::Event.new(:display_name => "url")
                        .display_name.must_equal "url"
    end

    it "should store a summary" do
      Nelumba::Event.new(:summary => "url").summary.must_equal "url"
    end

    it "should store a url" do
      Nelumba::Event.new(:url => "url").url.must_equal "url"
    end

    it "should store an id" do
      Nelumba::Event.new(:uid => "id").uid.must_equal "id"
    end

    it "should default attending array to empty array" do
      Nelumba::Event.new.attending.must_equal []
    end

    it "should default maybe attending array to empty array" do
      Nelumba::Event.new.maybe_attending.must_equal []
    end

    it "should default not attending array to empty array" do
      Nelumba::Event.new.not_attending.must_equal []
    end
  end

  describe "#to_hash" do
    it "should contain the content" do
      Nelumba::Event.new(:content => "Hello")
                        .to_hash[:content].must_equal "Hello"
    end

    it "should contain the author" do
      author = mock('Nelumba::Person')
      Nelumba::Event.new(:author => author).to_hash[:author].must_equal author
    end

    it "should contain the attending array" do
      Nelumba::Event.new(:attending => ["a","b"])
                  .to_hash[:attending].must_equal ["a","b"]
    end

    it "should contain the maybe attending array" do
      Nelumba::Event.new(:maybe_attending => ["a","b"])
                  .to_hash[:maybe_attending].must_equal ["a","b"]
    end

    it "should contain the not attending array" do
      Nelumba::Event.new(:not_attending => ["a","b"])
                  .to_hash[:not_attending].must_equal ["a","b"]
    end

    it "should contain the start time" do
      date = mock('Time')
      Nelumba::Event.new(:start_time => date)
                  .to_hash[:start_time].must_equal date
    end

    it "should contain the end time" do
      date = mock('Time')
      Nelumba::Event.new(:end_time => date)
                  .to_hash[:end_time].must_equal date
    end

    it "should contain the location" do
      Nelumba::Event.new(:location => "location")
                  .to_hash[:location].must_equal "location"
    end

    it "should contain the uid" do
      Nelumba::Event.new(:uid => "Hello").to_hash[:uid].must_equal "Hello"
    end

    it "should contain the url" do
      Nelumba::Event.new(:url => "Hello").to_hash[:url].must_equal "Hello"
    end

    it "should contain the summary" do
      Nelumba::Event.new(:summary=> "Hello")
                 .to_hash[:summary].must_equal "Hello"
    end

    it "should contain the display name" do
      Nelumba::Event.new(:display_name => "Hello")
                 .to_hash[:display_name].must_equal "Hello"
    end

    it "should contain the published date" do
      date = mock('Time')
      Nelumba::Event.new(:published => date).to_hash[:published].must_equal date
    end

    it "should contain the updated date" do
      date = mock('Time')
      Nelumba::Event.new(:updated => date).to_hash[:updated].must_equal date
    end
  end

  describe "#to_json" do
    before do
      author = Nelumba::Person.new :display_name => "wilkie"
      @note = Nelumba::Event.new :content         => "Hello",
                               :author          => author,
                               :attending       => ["a", "b"],
                               :maybe_attending => ["c", "d"],
                               :not_attending   => ["e", "f"],
                               :location        => "my house",
                               :start_time      => Time.now,
                               :end_time        => Time.now,
                               :uid             => "id",
                               :url             => "url",
                               :title           => "title",
                               :summary         => "foo",
                               :display_name    => "meh",
                               :published       => Time.now,
                               :updated         => Time.now

      @json = @note.to_json
      @data = JSON.parse(@json)
    end

    it "should contain the embedded json for the author" do
      @data["author"].must_equal JSON.parse(@note.author.to_json)
    end

    it "should contain a 'event' objectType" do
      @data["objectType"].must_equal "event"
    end

    it "should contain the id" do
      @data["id"].must_equal @note.uid
    end

    it "should contain the content" do
      @data["content"].must_equal @note.content
    end

    it "should contain the attending array" do
      @data["attending"].must_equal @note.attending
    end

    it "should contain the maybe attending array" do
      @data["maybeAttending"].must_equal @note.maybe_attending
    end

    it "should contain the not attending array" do
      @data["notAttending"].must_equal @note.not_attending
    end

    it "should contain the location" do
      @data["location"].must_equal @note.location
    end

    it "should contain the start time as rfc3339" do
      @data["startTime"].must_equal @note.start_time.to_date.rfc3339 + 'Z'
    end

    it "should contain the end time as rfc3339" do
      @data["endTime"].must_equal @note.end_time.to_date.rfc3339 + 'Z'
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
      @data["published"].must_equal @note.published.to_date.rfc3339 + 'Z'
    end

    it "should contain the updated date as rfc3339" do
      @data["updated"].must_equal @note.updated.to_date.rfc3339 + 'Z'
    end
  end
end

require_relative '../helper'
require_relative '../../lib/nelumba/feed.rb'
require_relative '../../lib/nelumba/atom/feed.rb'

# Sanity checks on atom generation because I don't trust ratom completely.
#
# Since I can't be completely sure how to test the implementations since they
# are patchy inheritance, I'll just do big acceptance tests and overtest.
# Somehow, these are still really fast.
describe Nelumba::Atom do
  before do
    author = Nelumba::Person.new(:url               => "http://example.com/users/1",
                                 :email             => "user@example.com",
                                 :name              => "wilkie",
                                 :uid => "1",
                                 :nickname    => "wilkie",
                                 :extended_name     => {:formatted => "Dave Wilkinson",
                                   :family_name => "Wilkinson",
                                   :given_name => "Dave",
                                   :middle_name => "William",
                                   :honorific_prefix => "Mr.",
                                   :honorific_suffix => "II"},
                                 :address => {:formatted => "123 Cherry Lane\nFoobar, PA, USA\n15206",
                                   :street_address => "123 Cherry Lane",
                                   :locality => "Foobar",
                                   :region => "PA",
                                   :postal_code => "15206",
                                   :country => "USA"},
                                 :organization => {:name => "Hackers of the Severed Hand",
                                   :department => "Making Shit",
                                   :title => "Founder",
                                   :type => "open source",
                                   :start_date => Date.today,
                                   :end_date => Date.today,
                                   :location => "everywhere",
                                   :description => "I make ostatus work"},
                                 :account     => {:domain => "example.com",
                                   :username => "wilkie",
                                   :userid => "1"},
                                 :gender      => "androgynous",
                                 :note        => "cool dude",
                                 :display_name => "Dave Wilkinson",
                                 :preferred_username => "wilkie",
                                 :updated     => Time.now,
                                 :published   => Time.now,
                                 :birthday    => Date.today,
                                 :anniversary => Date.today)

    source_feed = Nelumba::Feed.new(:title => "moo",
                                    :authors => [author],
                                    :rights => "CC")

    reply_to = Nelumba::Activity.new(:type  => :note,
                                     :actor => author,
                                     :verb  => :post,
                                     :object => Nelumba::Note.new(
                                       :title => "My First Entry",
                                       :html => "Hello"),
                                     :uid => "54321",
                                     :url => "http://example.com/entries/1",
                                     :published => Time.now,
                                     :updated => Time.now)

    entry = Nelumba::Activity.new(:actor  => author,
                                  :verb   => :post,
                                  :object => Nelumba::Note.new(
                                    :uid    => "54321",
                                    :url    => "http://example.com/entries/1",
                                    :title  => "My Entry",
                                    :html   => "Hello",
                                    :in_reply_to => reply_to,
                                    :author => author,
                                    :published => Time.now,
                                    :source => source_feed,
                                    :updated => Time.now))

    @master = Nelumba::Feed.new(:title => "My Feed",
                                :title_type => "html",
                                :subtitle => "Subtitle",
                                :subtitle_type => "html",
                                :url => "http://example.com/feeds/1",
                                :rights => "CC0",
                                :icon => "http://example.com/icon.png",
                                :logo => "http://example.com/logo.png",
                                :hubs => ["http://hub.example.com",
                                          "http://hub2.example.com"],
                                :published => Time.now,
                                :updated => Time.now,
                                :authors => [author],
                                :items => [entry],
                                :uid => "12345")
  end

  it "should be able to reform canonical structure using Atom" do
    xml = Nelumba::Atom::Feed.from_canonical(@master)
    new_feed = Nelumba::Atom::Feed.to_canonical(xml)

    old_hash = @master.to_hash
    new_hash = new_feed.to_hash

    old_hash[:authors] = old_hash[:authors].map(&:to_hash)
    new_hash[:authors] = new_hash[:authors].map(&:to_hash)

    old_hash[:items] = old_hash[:items].map(&:to_hash)
    new_hash[:items] = new_hash[:items].map(&:to_hash)

    old_hash[:items][0][:actors] = old_hash[:items][0][:actors].map(&:to_hash)
    new_hash[:items][0][:actors] = new_hash[:items][0][:actors].map(&:to_hash)

    old_hash[:items][0][:object] = old_hash[:items][0][:object].to_hash
    new_hash[:items][0][:object] = new_hash[:items][0][:object].to_hash

    old_hash[:items][0][:object][:in_reply_to] = []
    new_hash[:items][0][:object][:in_reply_to] = []

    old_hash[:items][0][:object][:source] = old_hash[:items][0][:object][:source].to_hash
    new_hash[:items][0][:object][:source] = new_hash[:items][0][:object][:source].to_hash

    old_hash[:items][0][:object][:authors] = old_hash[:items][0][:object][:authors].map(&:to_hash)
    new_hash[:items][0][:object][:authors] = new_hash[:items][0][:object][:authors].map(&:to_hash)

    old_hash[:items][0][:object][:source][:authors] = old_hash[:items][0][:object][:source][:authors].map(&:to_hash)
    new_hash[:items][0][:object][:source][:authors] = new_hash[:items][0][:object][:source][:authors].map(&:to_hash)

    # Flatten all keys to their to_s
    # We want to compare the to_s for all keys
    def flatten_keys!(hash)
      hash.keys.each do |k|
        if hash[k].is_a? Array
          # Go inside arrays (doesn't handle arrays of arrays)
          hash[k].map! do |e|
            if e.is_a? Hash
              flatten_keys! e
              e
            else
              e.to_s
            end
          end
        elsif hash[k].is_a? Hash
          # Go inside hashes
          flatten_keys!(hash[k])
        elsif hash[k].is_a? Time
          # Ensure all Time classes become DateTimes for comparison
          hash[k] = hash[k].to_datetime.to_s
        else
          # Ensure all fields become Strings
          hash[k] = hash[k].to_s
        end
      end
    end

    flatten_keys!(old_hash)
    flatten_keys!(new_hash)

    old_hash.must_equal new_hash
  end

  describe "<xml>" do
    before do
      @xml_str = Nelumba::Atom::Feed.from_canonical(@master)
      @xml = XML::Parser.string(@xml_str).parse
    end

    it "should publish a version of 1.0" do
      @xml_str.must_match /^<\?xml[^>]*\sversion="1\.0"/
    end

    it "should encode in utf-8" do
      @xml_str.must_match /^<\?xml[^>]*\sencoding="UTF-8"/
    end

    describe "<feed>" do
      before do
        @feed = @xml.root
      end

      it "should contain the Atom namespace" do
        @feed.namespaces.find_by_href("http://www.w3.org/2005/Atom").to_s
          .must_equal "http://www.w3.org/2005/Atom"
      end

      it "should contain the PortableContacts namespace" do
        @feed.namespaces.find_by_prefix('poco').to_s
          .must_equal "poco:http://portablecontacts.net/spec/1.0"
      end

      it "should contain the ActivityStreams namespace" do
        @feed.namespaces.find_by_prefix('activity').to_s
          .must_equal "activity:http://activitystrea.ms/spec/1.0/"
      end

      describe "<id>" do
        it "should contain the id from Nelumba::Feed" do
          @feed.find_first('xmlns:id', 'xmlns:http://www.w3.org/2005/Atom')
            .content.must_equal @master.uid
        end
      end

      describe "<rights>" do
        it "should contain the rights from Nelumba::Feed" do
          @feed.find_first('xmlns:rights', 'xmlns:http://www.w3.org/2005/Atom')
            .content.must_equal @master.rights
        end
      end

      describe "<logo>" do
        it "should contain the logo from Nelumba::Feed" do
          @feed.find_first('xmlns:logo', 'xmlns:http://www.w3.org/2005/Atom')
            .content.must_equal @master.logo
        end
      end

      describe "<icon>" do
        it "should contain the icon from Nelumba::Feed" do
          @feed.find_first('xmlns:icon', 'xmlns:http://www.w3.org/2005/Atom')
            .content.must_equal @master.icon
        end
      end

      describe "<published>" do
        it "should contain the time in the published field in Nelumba::Feed" do
          time = @feed.find_first('xmlns:published',
                                  'xmlns:http://www.w3.org/2005/Atom').content
          DateTime::rfc3339(time).to_s.must_equal @master.published.to_datetime.to_s
        end
      end

      describe "<updated>" do
        it "should contain the time in the updated field in Nelumba::Feed" do
          time = @feed.find_first('xmlns:updated',
                                  'xmlns:http://www.w3.org/2005/Atom').content
          DateTime::rfc3339(time).to_s.must_equal @master.updated.to_datetime.to_s
        end
      end

      describe "<link>" do
        it "should contain a link for the hub" do
          @feed.find_first('xmlns:link[@rel="hub"]',
                           'xmlns:http://www.w3.org/2005/Atom').attributes
             .get_attribute('href').value.must_equal(@master.hubs.first)
        end

        it "should allow a second link for the hub" do
          @feed.find('xmlns:link[@rel="hub"]',
                     'xmlns:http://www.w3.org/2005/Atom')[1].attributes
             .get_attribute('href').value.must_equal(@master.hubs[1])
        end

        it "should contain a link for self" do
          @feed.find_first('xmlns:link[@rel="self"]',
                           'xmlns:http://www.w3.org/2005/Atom').attributes
             .get_attribute('href').value.must_equal(@master.url)
        end
      end

      describe "<title>" do
        before do
          @title = @feed.find_first('xmlns:title', 'xmlns:http://www.w3.org/2005/Atom')
        end

        it "should contain the title from Nelumba::Feed" do
          @title.content.must_equal @master.title
        end

        it "should contain the type attribute from Nelumba::Feed" do
          @title.attributes.get_attribute('type').value.must_equal @master.title_type
        end
      end

      describe "<subtitle>" do
        before do
          @subtitle = @feed.find_first('xmlns:subtitle', 'xmlns:http://www.w3.org/2005/Atom')
        end

        it "should contain the subtitle from Nelumba::Feed" do
          @subtitle.content.must_equal @master.subtitle
        end

        it "should contain the type attribute from Nelumba::Feed" do
          @subtitle.attributes.get_attribute('type').value.must_equal @master.subtitle_type
        end
      end

      describe "<author>" do
        before do
          @author = @feed.find_first('xmlns:author', 'xmlns:http://www.w3.org/2005/Atom')
        end

        describe "<activity:object-type>" do
          it "should identify this tag as a person object" do
            @author.find_first('activity:object-type').content
              .must_equal "http://activitystrea.ms/schema/1.0/person"
          end
        end

        describe "<email>" do
          it "should list the author's email" do
            @author.find_first('xmlns:email',
                               'xmlns:http://www.w3.org/2005/Atom').content.must_equal @master.authors.first.email
          end
        end

        describe "<uri>" do
          it "should list the author's uri" do
            @author.find_first('xmlns:uri',
                               'xmlns:http://www.w3.org/2005/Atom').content.must_equal @master.authors.first.url
          end
        end

        describe "<name>" do
          it "should list the author's name" do
            @author.find_first('xmlns:name',
                               'xmlns:http://www.w3.org/2005/Atom').content.must_equal @master.authors.first.name
          end
        end

        describe "<poco:id>" do
          it "should list the author's portable contact id" do
            @author.find_first('poco:id',
                               'poco:http://portablecontacts.net/spec/1.0').content.must_equal @master.authors.first.uid
          end
        end

        describe "<poco:name>" do
          before do
            @poco_name = @author.find_first('poco:name',
                                            'poco:http://portablecontacts.net/spec/1.0')
          end

          describe "<formatted>" do
            it "should list the author's portable contact formatted name" do
              @poco_name.find_first('poco:formatted',
                                    'poco:http://portablecontacts.net/spec/1.0')
                .content.must_equal @master.authors.first.extended_name[:formatted]
            end
          end

          describe "<familyName>" do
            it "should list the author's portable contact family name" do
              @poco_name.find_first('poco:familyName',
                                    'poco:http://portablecontacts.net/spec/1.0')
                .content.must_equal @master.authors.first.extended_name[:family_name]
            end
          end

          describe "<givenName>" do
            it "should list the author's portable contact given name" do
              @poco_name.find_first('poco:givenName',
                                    'poco:http://portablecontacts.net/spec/1.0')
                .content.must_equal @master.authors.first.extended_name[:given_name]
            end
          end

          describe "<middleName>" do
            it "should list the author's portable contact middle name" do
              @poco_name.find_first('poco:middleName',
                                    'poco:http://portablecontacts.net/spec/1.0')
                .content.must_equal @master.authors.first.extended_name[:middle_name]
            end
          end

          describe "<honorificPrefix>" do
            it "should list the author's portable contact honorific prefix" do
              @poco_name.find_first('poco:honorificPrefix',
                                    'poco:http://portablecontacts.net/spec/1.0')
                .content.must_equal @master.authors.first.extended_name[:honorific_prefix]
            end
          end

          describe "<honorificSuffix>" do
            it "should list the author's portable contact honorific suffix" do
              @poco_name.find_first('poco:honorificSuffix',
                                    'poco:http://portablecontacts.net/spec/1.0')
                .content.must_equal @master.authors.first.extended_name[:honorific_suffix]
            end
          end
        end

        describe "<poco:organization>" do
          before do
            @poco_org = @author.find_first('poco:organization',
                                           'poco:http://portablecontacts.net/spec/1.0')
          end

          describe "<poco:name>" do
            it "should list the author's portable contact organization name" do
              @poco_org.find_first('poco:name',
                                   'poco:http://portablecontacts.net/spec/1.0')
                .content.must_equal @master.authors.first.organization[:name]
            end
          end

          describe "<poco:department>" do
            it "should list the author's portable contact organization department" do
              @poco_org.find_first('poco:department',
                                   'poco:http://portablecontacts.net/spec/1.0')
                .content.must_equal @master.authors.first.organization[:department]
            end
          end

          describe "<poco:title>" do
            it "should list the author's portable contact organization title" do
              @poco_org.find_first('poco:title',
                                   'poco:http://portablecontacts.net/spec/1.0')
                .content.must_equal @master.authors.first.organization[:title]
            end
          end

          describe "<poco:type>" do
            it "should list the author's portable contact organization type" do
              @poco_org.find_first('poco:type',
                                   'poco:http://portablecontacts.net/spec/1.0')
                .content.must_equal @master.authors.first.organization[:type]
            end
          end

          describe "<poco:startDate>" do
            it "should list the author's portable contact organization startDate" do
              time = @poco_org.find_first('poco:startDate',
                                          'poco:http://portablecontacts.net/spec/1.0')
                              .content
              DateTime::parse(time).to_s
                .must_equal @master.authors.first.organization[:start_date].to_datetime.to_s
            end
          end

          describe "<poco:endDate>" do
            it "should list the author's portable contact organization endDate" do
              time = @poco_org.find_first('poco:endDate',
                                          'poco:http://portablecontacts.net/spec/1.0')
                              .content
              DateTime::parse(time).to_s
                .must_equal @master.authors.first.organization[:end_date].to_datetime.to_s
            end
          end

          describe "<poco:location>" do
            it "should list the author's portable contact organization location" do
              @poco_org.find_first('poco:location',
                                   'poco:http://portablecontacts.net/spec/1.0')
                .content.must_equal @master.authors.first.organization[:location]
            end
          end

          describe "<poco:description>" do
            it "should list the author's portable contact organization description" do
              @poco_org.find_first('poco:description',
                                   'poco:http://portablecontacts.net/spec/1.0')
                .content.must_equal @master.authors.first.organization[:description]
            end
          end
        end

        describe "<poco:address>" do
          before do
            @poco_address = @author.find_first('poco:address',
                                               'poco:http://portablecontacts.net/spec/1.0')
          end

          describe "<poco:formatted>" do
            it "should list the author's portable contact formatted address" do
              @poco_address.find_first('poco:formatted',
                                       'poco:http://portablecontacts.net/spec/1.0')
                .content.must_equal @master.authors.first.address[:formatted]
            end
          end

          describe "<poco:streetAddress>" do
            it "should list the author's portable contact address streetAddress" do
              @poco_address.find_first('poco:streetAddress',
                                       'poco:http://portablecontacts.net/spec/1.0')
                .content.must_equal @master.authors.first.address[:street_address]
            end
          end

          describe "<poco:locality>" do
            it "should list the author's portable contact address locality" do
              @poco_address.find_first('poco:locality',
                                       'poco:http://portablecontacts.net/spec/1.0')
                .content.must_equal @master.authors.first.address[:locality]
            end
          end

          describe "<poco:region>" do
            it "should list the author's portable contact address region" do
              @poco_address.find_first('poco:region',
                                       'poco:http://portablecontacts.net/spec/1.0')
                .content.must_equal @master.authors.first.address[:region]
            end
          end

          describe "<poco:postalCode>" do
            it "should list the author's portable contact address postalCode" do
              @poco_address.find_first('poco:postalCode',
                                       'poco:http://portablecontacts.net/spec/1.0')
                .content.must_equal @master.authors.first.address[:postal_code]
            end
          end

          describe "<poco:country>" do
            it "should list the author's portable contact address country" do
              @poco_address.find_first('poco:country',
                                       'poco:http://portablecontacts.net/spec/1.0')
                .content.must_equal @master.authors.first.address[:country]
            end
          end
        end

        describe "<poco:account>" do
          before do
            @poco_account = @author.find_first('poco:account',
                                               'poco:http://portablecontacts.net/spec/1.0')
          end

          describe "<poco:domain>" do
            it "should list the author's portable contact account domain" do
              @poco_account.find_first('poco:domain',
                                       'poco:http://portablecontacts.net/spec/1.0')
                .content.must_equal @master.authors.first.account[:domain]
            end
          end

          describe "<poco:username>" do
            it "should list the author's portable contact account username" do
              @poco_account.find_first('poco:username',
                                       'poco:http://portablecontacts.net/spec/1.0')
                .content.must_equal @master.authors.first.account[:username]
            end
          end

          describe "<poco:userid>" do
            it "should list the author's portable contact account userid" do
              @poco_account.find_first('poco:userid',
                                       'poco:http://portablecontacts.net/spec/1.0')
                .content.must_equal @master.authors.first.account[:userid]
            end
          end
        end

        describe "<poco:displayName>" do
          it "should list the author's portable contact display name" do
            @author.find_first('poco:displayName',
                               'poco:http://portablecontacts.net/spec/1.0')
              .content.must_equal @master.authors.first.display_name
          end
        end

        describe "<poco:nickname>" do
          it "should list the author's portable contact nickname" do
            @author.find_first('poco:nickname',
                               'poco:http://portablecontacts.net/spec/1.0')
              .content.must_equal @master.authors.first.nickname
          end
        end

        describe "<poco:gender>" do
          it "should list the author's portable contact gender" do
            @author.find_first('poco:gender',
                               'poco:http://portablecontacts.net/spec/1.0')
              .content.must_equal @master.authors.first.gender
          end
        end

        describe "<poco:note>" do
          it "should list the author's portable contact note" do
            @author.find_first('poco:note',
                               'poco:http://portablecontacts.net/spec/1.0')
              .content.must_equal @master.authors.first.note
          end
        end

        describe "<poco:preferredUsername>" do
          it "should list the author's portable contact preferred username" do
            @author.find_first('poco:preferredUsername',
                               'poco:http://portablecontacts.net/spec/1.0')
              .content.must_equal @master.authors.first.preferred_username
          end
        end

        describe "<poco:birthday>" do
          it "should list the author's portable contact birthday" do
            time = @author.find_first('poco:birthday',
                                      'poco:http://portablecontacts.net/spec/1.0').content
            DateTime::parse(time).to_s.must_equal @master.authors.first
                                                       .birthday.to_datetime.to_s
          end
        end

        describe "<poco:anniversary>" do
          it "should list the author's portable contact anniversary" do
            time = @author.find_first('poco:anniversary',
                                      'poco:http://portablecontacts.net/spec/1.0').content
            DateTime::parse(time).to_s.must_equal @master.authors.first
                                                       .anniversary.to_datetime.to_s
          end
        end

        describe "<poco:published>" do
          it "should list the author's portable contact published date" do
            time = @author.find_first('poco:published',
                                      'poco:http://portablecontacts.net/spec/1.0').content
            DateTime::parse(time).to_s.must_equal @master.authors.first
                                                       .published.to_datetime.to_s
          end
        end

        describe "<poco:updated>" do
          it "should list the author's portable contact updated date" do
            time = @author.find_first('poco:updated',
                                      'poco:http://portablecontacts.net/spec/1.0').content
            DateTime::parse(time).to_s.must_equal @master.authors.first
                                                       .updated.to_datetime.to_s
          end
        end
      end

      describe "<entry>" do
        before do
          @entry = @feed.find_first('xmlns:entry', 'xmlns:http://www.w3.org/2005/Atom')
        end

        it "should have the thread namespace" do
          @entry.namespaces.find_by_prefix('thr').to_s
            .must_equal "thr:http://purl.org/syndication/thread/1.0"
        end

        it "should have the activity streams namespace" do
          @entry.namespaces.find_by_prefix('activity').to_s
            .must_equal "activity:http://activitystrea.ms/spec/1.0/"
        end

        describe "<title>" do
          it "should contain the entry title" do
            @entry.find_first('xmlns:title', 'xmlns:http://www.w3.org/2005/Atom')
              .content.must_equal @master.items.first.object.title
          end
        end

        describe "<id>" do
          it "should contain the entry id" do
            @entry.find_first('xmlns:id', 'xmlns:http://www.w3.org/2005/Atom')
              .content.must_equal @master.items.first.object.uid
          end
        end

        describe "<link>" do
          it "should contain a link for self" do
            @entry.find_first('xmlns:link[@rel="self"]',
                              'xmlns:http://www.w3.org/2005/Atom').attributes
               .get_attribute('href').value.must_equal(@master.items.first.object.url)
          end
        end

        describe "<updated>" do
          it "should contain the entry updated date" do
            time = @entry.find_first('xmlns:updated',
                                     'xmlns:http://www.w3.org/2005/Atom').content
            DateTime.parse(time).to_s.must_equal @master.items.first.updated.to_datetime.to_s
          end
        end

        describe "<published>" do
          it "should contain the entry published date" do
            time = @entry.find_first('xmlns:published',
                                     'xmlns:http://www.w3.org/2005/Atom').content
            DateTime.parse(time).to_s.must_equal @master.items.first.published.to_datetime.to_s
          end
        end

        describe "<activity:object-type>" do
          it "should reflect the activity for this entry" do
            @entry.find_first('activity:object-type').content
              .must_equal "http://activitystrea.ms/schema/1.0/note"
          end
        end

        describe "<content>" do
          it "should contain the entry content" do
            @entry.find_first('xmlns:content', 'xmlns:http://www.w3.org/2005/Atom')
              .content.must_equal @master.items.first.object.html
          end

          it "should have the corresponding type attribute" do
            @entry.find_first('xmlns:content', 'xmlns:http://www.w3.org/2005/Atom')
              .attributes.get_attribute('type').value.must_equal "html"
          end
        end
      end
    end
  end
end

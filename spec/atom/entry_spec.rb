require_relative '../helper'

require_relative '../../lib/nelumba/atom/entry'

describe Nelumba::Atom::Entry do
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

    @master = Nelumba::Activity.new(
      :verb => :post,
      :actor => author,
      :object => Nelumba::Comment.new(:content => "hello",
                                      :author => author,
                                      :display_name => "wilkie",
                                      :in_reply_to => [],
                                      :uid => "id",
                                      :published => Time.now,
                                      :updated => Time.now))
  end

  describe "<xml>" do
    before do
      @xml_str = Nelumba::Atom::Entry.from_canonical(@master)
      @xml = XML::Parser.string(@xml_str).parse
    end

    describe "<entry>" do
      before do
        @object = @xml.root
      end

      describe "<activity:object-type>" do
        it "should identify this tag as a comment object" do
          @object.find_first('activity:object-type').content
            .must_equal "http://activitystrea.ms/schema/1.0/comment"
        end
      end

      describe "<content>" do
        it "should contain the entry content" do
          @object.find_first('xmlns:content', 'xmlns:http://www.w3.org/2005/Atom')
            .content.must_equal @master.object.content
        end

        it "should have the corresponding type attribute of html" do
          @object.find_first('xmlns:content', 'xmlns:http://www.w3.org/2005/Atom')
            .attributes.get_attribute('type').value.must_equal "html"
        end
      end

      describe "<updated>" do
        it "should contain the entry updated date" do
          time = @object.find_first('xmlns:updated',
                                    'xmlns:http://www.w3.org/2005/Atom').content
          DateTime.parse(time).to_s.must_equal @master.object.updated.utc.to_datetime.to_s
        end
      end

      describe "<published>" do
        it "should contain the entry published date" do
          time = @object.find_first('xmlns:published',
                                   'xmlns:http://www.w3.org/2005/Atom').content
          DateTime.parse(time).to_s.must_equal @master.object.published.utc.to_datetime.to_s
        end
      end

      describe "<id>" do
        it "should contain the entry id" do
          @object.find_first('xmlns:id', 'xmlns:http://www.w3.org/2005/Atom')
            .content.must_equal @master.object.uid
        end
      end

      describe "<displayName>" do
        it "should contain the entry displayName" do
          @object.find_first('xmlns:displayName', 'xmlns:http://www.w3.org/2005/Atom')
            .content.must_equal @master.object.display_name
        end
      end

      describe "<author>" do
        before do
          @author = @object.find_first('xmlns:author', 'xmlns:http://www.w3.org/2005/Atom')
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
                               'xmlns:http://www.w3.org/2005/Atom')
                   .content.must_equal @master.object.authors.first.email
          end
        end

        describe "<uri>" do
          it "should list the author's uri" do
            @author.find_first('xmlns:uri',
                               'xmlns:http://www.w3.org/2005/Atom')
                   .content.must_equal @master.object.authors.first.url
          end
        end

        describe "<name>" do
          it "should list the author's name" do
            @author.find_first('xmlns:name',
                               'xmlns:http://www.w3.org/2005/Atom')
                   .content.must_equal @master.object.authors.first.name
          end
        end

        describe "<poco:id>" do
          it "should list the author's portable contact id" do
            @author.find_first('poco:id',
                               'http://portablecontacts.net/spec/1.0')
                   .content.must_equal @master.object.authors.first.uid
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
                .content.must_equal @master.object.authors.first.extended_name[:formatted]
            end
          end

          describe "<familyName>" do
            it "should list the author's portable contact family name" do
              @poco_name.find_first('poco:familyName',
                                    'poco:http://portablecontacts.net/spec/1.0')
                .content.must_equal @master.object.authors.first.extended_name[:family_name]
            end
          end

          describe "<givenName>" do
            it "should list the author's portable contact given name" do
              @poco_name.find_first('poco:givenName',
                                    'poco:http://portablecontacts.net/spec/1.0')
                .content.must_equal @master.object.authors.first.extended_name[:given_name]
            end
          end

          describe "<middleName>" do
            it "should list the author's portable contact middle name" do
              @poco_name.find_first('poco:middleName',
                                    'poco:http://portablecontacts.net/spec/1.0')
                .content.must_equal @master.object.authors.first.extended_name[:middle_name]
            end
          end

          describe "<honorificPrefix>" do
            it "should list the author's portable contact honorific prefix" do
              @poco_name.find_first('poco:honorificPrefix',
                                    'poco:http://portablecontacts.net/spec/1.0')
                .content.must_equal @master.object.authors.first.extended_name[:honorific_prefix]
            end
          end

          describe "<honorificSuffix>" do
            it "should list the author's portable contact honorific suffix" do
              @poco_name.find_first('poco:honorificSuffix',
                                    'poco:http://portablecontacts.net/spec/1.0')
                .content.must_equal @master.object.authors.first.extended_name[:honorific_suffix]
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
                .content.must_equal @master.object.authors.first.organization[:name]
            end
          end

          describe "<poco:department>" do
            it "should list the author's portable contact organization department" do
              @poco_org.find_first('poco:department',
                                   'poco:http://portablecontacts.net/spec/1.0')
                .content.must_equal @master.object.authors.first.organization[:department]
            end
          end

          describe "<poco:title>" do
            it "should list the author's portable contact organization title" do
              @poco_org.find_first('poco:title',
                                   'poco:http://portablecontacts.net/spec/1.0')
                .content.must_equal @master.object.authors.first.organization[:title]
            end
          end

          describe "<poco:type>" do
            it "should list the author's portable contact organization type" do
              @poco_org.find_first('poco:type',
                                   'poco:http://portablecontacts.net/spec/1.0')
                .content.must_equal @master.object.authors.first.organization[:type]
            end
          end

          describe "<poco:startDate>" do
            it "should list the author's portable contact organization startDate" do
              time = @poco_org.find_first('poco:startDate',
                                          'poco:http://portablecontacts.net/spec/1.0')
                              .content
              DateTime::parse(time).to_s
                .must_equal @master.object.authors.first.organization[:start_date].to_datetime.to_s
            end
          end

          describe "<poco:endDate>" do
            it "should list the author's portable contact organization endDate" do
              time = @poco_org.find_first('poco:endDate',
                                          'poco:http://portablecontacts.net/spec/1.0')
                              .content
              DateTime::parse(time).to_s
                .must_equal @master.object.authors.first.organization[:end_date].to_datetime.to_s
            end
          end

          describe "<poco:location>" do
            it "should list the author's portable contact organization location" do
              @poco_org.find_first('poco:location',
                                   'poco:http://portablecontacts.net/spec/1.0')
                .content.must_equal @master.object.authors.first.organization[:location]
            end
          end

          describe "<poco:description>" do
            it "should list the author's portable contact organization description" do
              @poco_org.find_first('poco:description',
                                   'poco:http://portablecontacts.net/spec/1.0')
                .content.must_equal @master.object.authors.first.organization[:description]
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
                .content.must_equal @master.object.authors.first.address[:formatted]
            end
          end

          describe "<streetAddress>" do
            it "should list the author's portable contact address streetAddress" do
              @poco_address.find_first('poco:streetAddress',
                                       'poco:http://portablecontacts.net/spec/1.0')
                .content.must_equal @master.object.authors.first.address[:street_address]
            end
          end

          describe "<locality>" do
            it "should list the author's portable contact address locality" do
              @poco_address.find_first('poco:locality',
                                       'poco:http://portablecontacts.net/spec/1.0')
                .content.must_equal @master.object.authors.first.address[:locality]
            end
          end

          describe "<region>" do
            it "should list the author's portable contact address region" do
              @poco_address.find_first('poco:region',
                                       'poco:http://portablecontacts.net/spec/1.0')
                .content.must_equal @master.object.authors.first.address[:region]
            end
          end

          describe "<postalCode>" do
            it "should list the author's portable contact address postalCode" do
              @poco_address.find_first('poco:postalCode',
                                       'poco:http://portablecontacts.net/spec/1.0')
                .content.must_equal @master.object.authors.first.address[:postal_code]
            end
          end

          describe "<country>" do
            it "should list the author's portable contact address country" do
              @poco_address.find_first('poco:country',
                                       'poco:http://portablecontacts.net/spec/1.0')
                .content.must_equal @master.object.authors.first.address[:country]
            end
          end
        end

        describe "<poco:account>" do
          before do
            @poco_account = @author.find_first('poco:account',
                                               'poco:http://portablecontacts.net/spec/1.0')
          end

          describe "<domain>" do
            it "should list the author's portable contact account domain" do
              @poco_account.find_first('poco:domain',
                                       'poco:http://portablecontacts.net/spec/1.0')
                .content.must_equal @master.object.authors.first.account[:domain]
            end
          end

          describe "<username>" do
            it "should list the author's portable contact account username" do
              @poco_account.find_first('poco:username',
                                       'poco:http://portablecontacts.net/spec/1.0')
                .content.must_equal @master.object.authors.first.account[:username]
            end
          end

          describe "<userid>" do
            it "should list the author's portable contact account userid" do
              @poco_account.find_first('poco:userid',
                                       'poco:http://portablecontacts.net/spec/1.0')
                .content.must_equal @master.object.authors.first.account[:userid]
            end
          end
        end

        describe "<poco:displayName>" do
          it "should list the author's portable contact display name" do
            @author.find_first('poco:displayName',
                               'poco:http://portablecontacts.net/spec/1.0')
              .content.must_equal @master.object.authors.first.display_name
          end
        end

        describe "<poco:nickname>" do
          it "should list the author's portable contact nickname" do
            @author.find_first('poco:nickname',
                               'poco:http://portablecontacts.net/spec/1.0')
              .content.must_equal @master.object.authors.first.nickname
          end
        end

        describe "<poco:gender>" do
          it "should list the author's portable contact gender" do
            @author.find_first('poco:gender',
                               'poco:http://portablecontacts.net/spec/1.0')
              .content.must_equal @master.object.authors.first.gender
          end
        end

        describe "<poco:note>" do
          it "should list the author's portable contact note" do
            @author.find_first('poco:note',
                               'poco:http://portablecontacts.net/spec/1.0')
              .content.must_equal @master.object.authors.first.note
          end
        end

        describe "<poco:preferredUsername>" do
          it "should list the author's portable contact preferred username" do
            @author.find_first('poco:preferredUsername',
                               'poco:http://portablecontacts.net/spec/1.0')
              .content.must_equal @master.object.authors.first.preferred_username
          end
        end

        describe "<poco:birthday>" do
          it "should list the author's portable contact birthday" do
            time = @author.find_first('poco:birthday',
                                      'poco:http://portablecontacts.net/spec/1.0')
                          .content
            DateTime::parse(time).to_s.must_equal @master.object.authors.first
                                                       .birthday.to_datetime.to_s
          end
        end

        describe "<poco:anniversary>" do
          it "should list the author's portable contact anniversary" do
            time = @author.find_first('poco:anniversary',
                                      'poco:http://portablecontacts.net/spec/1.0')
                          .content
            DateTime::parse(time).to_s.must_equal @master.object.authors.first
                                                       .anniversary.to_datetime.to_s
          end
        end

        describe "<poco:published>" do
          it "should list the author's portable contact published date" do
            time = @author.find_first('poco:published',
                                      'poco:http://portablecontacts.net/spec/1.0')
                          .content
            DateTime::parse(time).to_s.must_equal @master.object.authors.first
                                                       .published.utc.to_datetime.to_s
          end
        end

        describe "<poco:updated>" do
          it "should list the author's portable contact updated date" do
            time = @author.find_first('poco:updated',
                                      'poco:http://portablecontacts.net/spec/1.0')
                          .content
            DateTime::parse(time).to_s.must_equal @master.object.authors.first
                                                       .updated.utc.to_datetime.to_s
          end
        end
      end
    end
  end
end

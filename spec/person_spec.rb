require_relative 'helper'
require_relative '../lib/nelumba/person.rb'

describe Nelumba::Person do
  describe "#initialize" do
    it "should store an uri" do
      Nelumba::Person.new(:uri => "http://example.com/1").uri.must_equal "http://example.com/1"
    end

    it "should store a name" do
      Nelumba::Person.new(:name => "foo").name.must_equal "foo"
    end

    it "should store a email" do
      Nelumba::Person.new(:email => "foo@example.com").email.must_equal "foo@example.com"
    end

    it "should store a id" do
      Nelumba::Person.new(:uid => "1").uid.must_equal "1"
    end

    it "should store a gender" do
      Nelumba::Person.new(:gender => "androgynous").gender.must_equal "androgynous"
    end

    it "should store nickname" do
      Nelumba::Person.new(:nickname => "foobar").nickname.must_equal "foobar"
    end

    it "should store the display name" do
      Nelumba::Person.new(:display_name => "foobar").display_name.must_equal "foobar"
    end

    it "should store the preferred username" do
      Nelumba::Person.new(:preferred_username => "foobar")
        .preferred_username.must_equal "foobar"
    end

    it "should store the pronoun" do
      pronoun = mock('hash')
      Nelumba::Person.new(:pronoun => pronoun).pronoun.must_equal pronoun
    end

    it "should store the birthday" do
      time = mock('datetime')
      Nelumba::Person.new(:birthday => time).birthday.must_equal time
    end

    it "should store the anniversary" do
      time = mock('datetime')
      Nelumba::Person.new(:anniversary => time).anniversary.must_equal time
    end

    it "should store the note" do
      Nelumba::Person.new(:note => "note").note.must_equal "note"
    end

    it "should store the published date" do
      time = mock('datetime')
      Nelumba::Person.new(:published => time).published.must_equal time
    end

    it "should store the updated date" do
      time = mock('datetime')
      Nelumba::Person.new(:updated => time).updated.must_equal time
    end

    it "should store an address hash" do
      address = mock('hash')
      Nelumba::Person.new(:address => address).address.must_equal address
    end

    it "should store an organization hash" do
      organization = mock('hash')
      Nelumba::Person.new(:organization => organization).organization.must_equal organization
    end

    it "should store an extended name hash" do
      name = mock('hash')
      Nelumba::Person.new(:extended_name => name).extended_name.must_equal name
    end

    it "should store an account hash" do
      account = mock('hash')
      Nelumba::Person.new(:account => account).account.must_equal account
    end
  end

  describe "#to_hash" do
    it "should return a Hash containing the uid" do
      Nelumba::Person.new(:uid => "1").to_hash[:uid].must_equal "1"
    end

    it "should return a Hash containing the gender" do
      Nelumba::Person.new(:gender => "androgynous").to_hash[:gender].must_equal "androgynous"
    end

    it "should return a Hash containing nickname" do
      Nelumba::Person.new(:nickname => "foobar").to_hash[:nickname].must_equal "foobar"
    end

    it "should return a Hash containing the display name" do
      Nelumba::Person.new(:display_name => "foobar").display_name.must_equal "foobar"
    end

    it "should return a Hash containing the preferred username" do
      Nelumba::Person.new(:preferred_username => "foobar")
        .preferred_username.must_equal "foobar"
    end

    it "should return a Hash containing the preferred username" do
      pronoun = mock('hash')
      Nelumba::Person.new(:pronoun => pronoun).to_hash[:pronoun].must_equal pronoun
    end

    it "should return a Hash containing the birthday" do
      time = mock('datetime')
      Nelumba::Person.new(:birthday => time).to_hash[:birthday].must_equal time
    end

    it "should return a Hash containing the anniversary" do
      time = mock('datetime')
      Nelumba::Person.new(:anniversary => time).to_hash[:anniversary].must_equal time
    end

    it "should return a Hash containing the note" do
      Nelumba::Person.new(:note => "note").to_hash[:note].must_equal "note"
    end

    it "should return a Hash containing the published date" do
      time = mock('datetime')
      Nelumba::Person.new(:published => time).to_hash[:published].must_equal time
    end

    it "should return a Hash containing the updated date" do
      time = mock('datetime')
      Nelumba::Person.new(:updated => time).to_hash[:updated].must_equal time
    end

    it "should return a Hash containing the address hash" do
      address = mock('hash')
      Nelumba::Person.new(:address => address).to_hash[:address].must_equal address
    end

    it "should return a Hash containing the organization hash" do
      organization = mock('hash')
      Nelumba::Person.new(:organization => organization).to_hash[:organization].must_equal organization
    end

    it "should return a Hash containing the extended name hash" do
      name = mock('hash')
      Nelumba::Person.new(:extended_name => name).to_hash[:extended_name].must_equal name
    end

    it "should return a Hash containing the account hash" do
      account = mock('hash')
      Nelumba::Person.new(:account => account).to_hash[:account].must_equal account
    end
  end

  describe "#preferred_display_name" do
    it "should use display_name over all else" do
      author = Nelumba::Person.new(:display_name       => "display",
                                   :name               => "name",
                                   :preferred_username => "preferred",
                                   :nickname           => "nickname",
                                   :uid                => "unique")

      author.preferred_display_name.must_equal "display"
    end

    it "should use name over all else when display name doesn't exist" do
      author = Nelumba::Person.new(:name               => "name",
                                   :preferred_username => "preferred",
                                   :nickname           => "nickname",
                                   :uid                => "unique")

      author.preferred_display_name.must_equal "name"
    end

    it "should use preferred_username when name and display_name don't exist" do
      author = Nelumba::Person.new(:preferred_username => "preferred",
                                   :nickname           => "nickname",
                                   :uid                => "unique")

      author.preferred_display_name.must_equal "preferred"
    end

    it "should use nickname when it exists and others do not" do
      author = Nelumba::Person.new(:nickname => "nickname",
                                   :uid      => "unique")

      author.preferred_display_name.must_equal "nickname"
    end

    it "should use uid when all else fails" do
      author = Nelumba::Person.new(:uid => "unique")

      author.preferred_display_name.must_equal "unique"
    end
  end

  describe "#preferred_short_name" do
    it "should use preferred_username over all else" do
      author = Nelumba::Person.new(:display_name       => "display",
                                   :name               => "name",
                                   :preferred_username => "preferred",
                                   :nickname           => "nickname",
                                   :uid                => "unique")

      author.preferred_short_name.must_equal "preferred"
    end

    it "should use nickname over all else when preferred_username name doesn't exist" do
      author = Nelumba::Person.new(:name         => "name",
                                   :display_name => "display",
                                   :nickname     => "nickname",
                                   :uid          => "unique")

      author.preferred_short_name.must_equal "nickname"
    end

    it "should use display_name when nickname and preferred_username don't exist" do
      author = Nelumba::Person.new(:name         => "name",
                                   :display_name => "display",
                                   :uid          => "unique")

      author.preferred_short_name.must_equal "display"
    end

    it "should use name when it exists and others do not" do
      author = Nelumba::Person.new(:name => "name",
                                   :uid  => "unique")

      author.preferred_short_name.must_equal "name"
    end

    it "should use uid when all else fails" do
      author = Nelumba::Person.new(:uid => "unique")

      author.preferred_short_name.must_equal "unique"
    end
  end
end

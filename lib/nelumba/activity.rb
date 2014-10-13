module Nelumba
  # This class represents an Activity object that represents an action taken
  # by a Person.
  class Activity
    include Nelumba::Object

    # The object of this activity.
    attr_reader :object

    # The action being invoked in this activity.
    #
    # The field can be a String for uncommon verbs. Several are standard:
    #   :favorite, :follow, :like, :"make-friend", :join, :play,
    #   :post, :save, :share, :tag, :update
    attr_reader :verb

    # The target of the action.
    attr_reader :target

    # Holds an Nelumba::Person.
    attr_reader :actors

    # Create a new entry with the given action and object.
    #
    # options:
    #   :object       => The object of this activity.
    #   :target       => The target of this activity.
    #   :verb         => The action of the activity.
    #
    #   :actor        => An Nelumba::Person responsible for generating this entry.
    #   :source       => An Nelumba::Feed where this Entry originated. This
    #                    should be used when an Entry is copied into this feed
    #                    from another.
    #   :published    => The DateTime depicting when the entry was originally
    #                    published.
    #   :updated      => The DateTime depicting when the entry was modified.
    #   :url          => The canonical url of the entry.
    #   :uid          => The unique id that identifies this entry.
    #   :in_reply_to  => An Nelumba::Entry for which this entry is a response.
    #                    Or an array of Nelumba::Entry's that this entry is a
    #                    response to. Use this when this Entry is a reply
    #                    to an existing Entry.
    def initialize(options = {}, &blk)
      super(options, &blk)
    end

    def init(options = {}, &blk)
      options[:type] = :activity

      super(options, &blk)

      @object       = options[:object]

      @target       = options[:target]
      @verb         = options[:verb]

      if options.has_key? :actor
        if options[:actor].is_a? Array
          options[:actors] = options[:actor]
        else
          options[:actors] = [options[:actor]]
        end
        options.delete :actor
      end

      @actors       = options[:actors] || []
      @published    = options[:published]
      @updated      = options[:updated]
      @url          = options[:url]
      @uid          = options[:uid]
    end

    # Returns a hash of all relevant fields.
    def to_hash(scheme = 'https', domain = 'example.org', port = nil)
      {
        :object => self.object,
        :target => self.target,
        :actors => self.actors,
        :verb   => self.verb,
      }.merge(super(scheme, domain, port))
    end

    # Returns a string containing the Atom representation of this Activity.
    def to_atom
      require 'nelumba/atom/entry'

      Nelumba::Atom::Entry.from_canonical(self).to_xml
    end

    # Returns a hash of all relevant fields with JSON activity streams
    # conventions.
    def to_json_hash(scheme = 'https', domain = 'example.org', port = nil)
      {
        :object     => @object,
        :actors     => @actors,
        :target     => @target,
        :verb       => @verb,
        :source     => self.source,
      }.merge(super(scheme, domain, port))
    end

    # Generates a sentence describing this activity in the current or given
    # locale.
    #
    # Usage:
    #   # The default locale
    #   Nelumba::Activity.new(:verb => :post,
    #                         :object => Nelumba::Note(:content => "hello"),
    #                         :actor => Nelumba::Person.new(:name => "wilkie"))
    #                    .sentence
    #   # => "wilkie posted a note"
    #
    #   Nelumba::Activity.new(:verb => :follow,
    #                         :object => Nelumba::Person.new(:name => "carol"),
    #                         :actor => Nelumba::Person.new(:name => "wilkie"))
    #                    .sentence
    #   # => "wilkie followed carol"
    #
    #   # In Spanish
    #   Nelumba::Activity.new(:verb => :post,
    #                         :object => Nelumba::Note(:content => "hello"),
    #                         :actor => Nelumba::Person.new(:name => "wilkie"))
    #                    .sentence(:locale => :es)
    #   # => "wilkie puso una nota"
    def sentence(options = {})
      object_owner = nil

      if self.verb == :favorite || self.verb == :share
        if self.object.first_author
          object_owners = self.object.authors.map(&:name)
        elsif self.object.actors and self.object.actors.first.is_a? Nelumba::Person
          object_owners = self.object.actors.map(&:name)
        end
      end

      object = self.type

      if self.verb == :favorite || self.verb == :share
        if self.object
          object = self.object.type
        end
      end

      actors = nil

      if self.actors
        actors = self.actors.map(&:preferred_display_name)
      end

      person = nil

      if self.object.is_a?(Nelumba::Person)
        person = self.object.name
      end

      Nelumba::I18n.sentence({
        :actors        => actors,
        :object        => object,
        :object_owners => object_owners,
        :person        => person,
        :verb          => self.verb,
        :target        => self.target ? self.target.preferred_display_name : nil
      }.merge(options))
    end
  end
end

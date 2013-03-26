require_relative 'helper'
require_relative '../lib/lotus/link.rb'

describe Lotus::Link do
  describe "#initialize" do
    it "should store an href" do
      Lotus::Link.new(:href => "object").href.must_equal "object"
    end

    it "should store an type" do
      Lotus::Link.new(:type => "html").type.must_equal "html"
    end

    it "should store a hreflang" do
      Lotus::Link.new(:hreflang => :follow).hreflang.must_equal :follow
    end

    it "should store a title" do
      Lotus::Link.new(:title => "Title").title.must_equal "Title"
    end

    it "should store a rel" do
      Lotus::Link.new(:rel => "alternate").rel.must_equal "alternate"
    end

    it "should store a length" do
      Lotus::Link.new(:length => 12345).length.must_equal 12345
    end
  end
end

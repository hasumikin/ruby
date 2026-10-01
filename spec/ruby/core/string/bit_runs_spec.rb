# encoding: binary
require_relative '../../spec_helper'

ruby_version_is "4.1" do
  describe "String#bit_runs" do
    it "returns an Array of [bit, offset, length] for each run in LSB-first order by default" do
      "\x0F\x01".bit_runs.should == [[1, 0, 4], [0, 4, 4], [1, 8, 1], [0, 9, 7]]
    end

    it "returns the runs in MSB-first order when lsb_first is false" do
      "\x0F".bit_runs(lsb_first: false).should == [[0, 0, 4], [1, 4, 4]]
    end

    it "returns the runs of a region" do
      "\x0F\x01".bit_runs(8..).should == [[1, 8, 1], [0, 9, 7]]
    end

    it "clamps a region that extends past the end of the string" do
      "\x0F\x01".bit_runs(12, 100).should == [[0, 12, 4]]
      "\x0F\x01".bit_runs(100, 8).should == []
    end

    it "returns an empty Array for an empty string" do
      "".bit_runs.should == []
    end

    it "yields each run and returns self when a block is given" do
      str = "\x0F"
      runs = []
      str.bit_runs { |bit, offset, length| runs << [bit, offset, length] }.should equal(str)
      runs.should == [[1, 0, 4], [0, 4, 4]]
    end

    it "raises an ArgumentError for a lone offset without a length" do
      -> { "\x00".bit_runs(0) }.should.raise(ArgumentError)
    end
  end
end

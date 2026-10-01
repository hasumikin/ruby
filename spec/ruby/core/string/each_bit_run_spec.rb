# encoding: binary
require_relative '../../spec_helper'

ruby_version_is "4.1" do
  describe "String#each_bit_run" do
    it "yields the bit, offset and length of each run in LSB-first order by default" do
      runs = []
      "\x0F\x01".each_bit_run { |bit, offset, length| runs << [bit, offset, length] }
      runs.should == [[1, 0, 4], [0, 4, 4], [1, 8, 1], [0, 9, 7]]
    end

    it "yields runs in MSB-first order when lsb_first is false" do
      "\x0F".each_bit_run(lsb_first: false).to_a.should == [[0, 0, 4], [1, 4, 4]]
    end

    it "yields one run for a string of equal bits" do
      ("\xFF" * 4).each_bit_run.to_a.should == [[1, 0, 32]]
    end

    it "returns self when a block is given" do
      str = "\x0F"
      str.each_bit_run { }.should equal(str)
    end

    it "returns a sized Enumerator when no block is given" do
      enum = "\x0F\x01".each_bit_run
      enum.should be_an_instance_of(Enumerator)
      enum.size.should == 4
      "\x0F\x01".each_bit_run(8..).size.should == 2
    end

    it "cuts the runs at the region boundaries and yields absolute offsets" do
      "\x0F\x01".each_bit_run(2, 8).to_a.should == [[1, 2, 2], [0, 4, 4], [1, 8, 1], [0, 9, 1]]
      "\x0F\x01".each_bit_run(8..).to_a.should == [[1, 8, 1], [0, 9, 7]]
    end

    it "clamps a region that extends past the end of the string" do
      "\x0F\x01".each_bit_run(12, 100).to_a.should == [[0, 12, 4]]
      "\x0F\x01".each_bit_run(100, 8).to_a.should == []
    end

    it "yields nothing for an empty string" do
      "".each_bit_run.to_a.should == []
    end

    it "stops at the new end when the block shrinks the string" do
      str = "\x0F\x0F"
      runs = []
      str.each_bit_run { |bit, offset, length| runs << [bit, offset, length]; str.replace("\x0F") if runs.size == 1 }
      runs.should == [[1, 0, 4], [0, 4, 4]]
    end

    it "raises an ArgumentError for a lone offset without a length" do
      -> { "\x00".each_bit_run(0) }.should.raise(ArgumentError)
    end

    it "raises for an invalid region" do
      -> { "\x00".each_bit_run(-1, 4) }.should.raise(IndexError)
      -> { "\x00".each_bit_run(0, -1) }.should.raise(ArgumentError)
      -> { "\x00".each_bit_run(0..3, 4) }.should.raise(ArgumentError)
      -> { "\x00".each_bit_run(lsb_first: nil) }.should.raise(ArgumentError)
    end
  end
end

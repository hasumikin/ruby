# encoding: binary
require_relative '../../spec_helper'

ruby_version_is "4.1" do
  describe "String#bit_run_length" do
    it "returns the number of consecutive bits equal to bit from offset in LSB-first order by default" do
      "\x0F\x01".bit_run_length(1, 0).should == 4
      "\x0F\x01".bit_run_length(0, 4).should == 4
      "\x0F\x01".bit_run_length(0, 9).should == 7
    end

    it "returns 0 when the bit at offset differs from bit" do
      "\x0F\x01".bit_run_length(1, 4).should == 0
      "\x0F\x01".bit_run_length(0, 0).should == 0
    end

    it "accepts true and false as the bit value" do
      "\x0F\x01".bit_run_length(true, 0).should == 4
      "\x0F\x01".bit_run_length(false, 4).should == 4
    end

    it "counts across byte boundaries" do
      ("\xFF" * 8).bit_run_length(1, 3).should == 61
    end

    it "counts in MSB-first order when lsb_first is false" do
      "\x0F".bit_run_length(0, 0, lsb_first: false).should == 4
      "\x0F".bit_run_length(1, 4, lsb_first: false).should == 4
    end

    it "returns nil when offset is at or beyond the end of the string" do
      "\x0F\x01".bit_run_length(1, 16).should == nil
      "".bit_run_length(0, 0).should == nil
    end

    it "raises for an invalid bit value" do
      -> { "\x00".bit_run_length(2, 0) }.should.raise(ArgumentError)
      -> { "\x00".bit_run_length(nil, 0) }.should.raise(TypeError)
    end

    it "raises for an invalid offset" do
      -> { "\x00".bit_run_length(1, -1) }.should.raise(IndexError)
      -> { "\x00".bit_run_length(1, nil) }.should.raise(TypeError)
      -> { "\x00".bit_run_length(1, 0, lsb_first: nil) }.should.raise(ArgumentError)
    end
  end
end

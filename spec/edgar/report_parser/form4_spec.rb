require 'edgar'

describe Edgar::ReportParser::Form4 do
  describe ".parse" do
    before do
      xml = File.read('spec/support/form4.txt')
      @parsed = Edgar::ReportParser::Form4.new.parse(xml)
    end

    it "should have form_type set" do
      expect(@parsed[:form_type]).to be_eql('4')
    end

    it "should have issuer set" do
      expect(@parsed[:issuer]).to be_a(Hash)
      expect(@parsed[:issuer][:name]).to be_eql('Fake Name')
      expect(@parsed[:issuer][:cik]).to be_eql('1111111111')
      expect(@parsed[:issuer][:symbol]).to be_eql('FAKE')
    end

    it "should have owner set" do
      expect(@parsed[:owner]).to be_a(Hash)
      expect(@parsed[:owner][:name]).to be_eql('Fake Name2')
      expect(@parsed[:owner][:cik]).to be_eql('2222222222')
      expect(@parsed[:owner][:relationship]).to be_eql(:officer)
    end

    it "should have non_derivative set" do
      expect(@parsed[:non_derivative]).to be_a(Array)
    end
  end
end

require 'edgar'

describe Edgar::Report do
  describe ".new" do
    before do
      xml = File.read('spec/support/form4.txt')
      @report = build(:report, xml: xml, uri: 'fake/uri/form4.txt')
    end

    it "should accept xml and uri params" do
      expect(@report.xml).not_to be_nil
      expect(@report.uri).not_to be_nil
    end
  end

  describe ".parse" do
    before do
      xml = File.read('spec/support/form4.txt')
      @parsed = build(:report, xml: xml, uri: 'fake/uri/form4.txt').parse
    end

    it "meta keys should be set" do
      expect(@parsed[:uri]).to be_eql('fake/uri/form4.txt')
      expect(@parsed[:filename]).to be_eql('0001209191-17-005534.txt')
      expect(@parsed[:basename]).to be_eql('0001209191-17-005534.txt')
      expect(@parsed[:fill_date]).not_to be_nil
      expect(@parsed[:form_type]).to be_eql('4')
    end
  end

  describe ".get_parser" do
    before do
      @report = build(:report)
    end

    it "should get parser for form 4" do
      expect(@report.get_parser("4")).to be_a(Edgar::ReportParser::Form4)
      expect(@report.get_parser("13F-HR")).to be_a(Edgar::ReportParser::Form13f)
      expect(@report.get_parser("13F-HR/A")).to be_a(Edgar::ReportParser::Form13f)
      expect { @report.get_parser("fake") }.to raise_error(Edgar::ReportUnknownType)
    end
  end
end

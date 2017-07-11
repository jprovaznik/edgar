require 'edgar'

describe Edgar::Index do
  describe ".report_list" do
    before do
      @index = build(:index, accepted_form_types: ['4', '13F-HR'])
    end

    it "should return an array of report info objects" do
      expect(@index.report_list).to be_a(Array)
      @index.report_list.each do |r|
        expect(r).to be_a(Edgar::IndexReportInfo)
      end
    end

    it "each object should have all attributes set" do
      @index.report_list.each do |r|
        expect(r.cik).not_to be_nil
        expect(r.company).not_to be_nil
        expect(r.form_type).not_to be_nil
        expect(r.basename).not_to be_nil
        expect(r.filename).not_to be_nil
      end
    end

    it "should return only accepted form types" do
      expect(@index.report_list).not_to be_empty
      expect(@index.report_list.length).to eq(5)
      expect(@index.report_list.map(&:form_type).uniq).to match_array(['4', '13F-HR'])
    end
  end
end

require 'edgar'
require 'time'
require 'timecop'

describe Edgar::IndexList do
  #before do
  #  @existing = create(:location)
  #end

  describe ".days_since" do
    it "should contain no urls if 'since' is in future" do
      expect(Edgar::IndexList.days_since(Date.today+1).urls).to be_empty
    end

    it "should contain urls if 'since' already was" do
      Timecop.freeze(Time.parse('2017-03-11'))
      expected_list = [
        "edgar/daily-index/2017/QTR1/master.20170310.idx",
        "edgar/daily-index/2017/QTR1/master.20170311.idx"
      ]
      list = Edgar::IndexList.days_since(Date.today-1)
      expect(list.urls).to match_array(expected_list)
    end
  end

  describe ".days" do
    it "should contain urls" do
      expected_list = [
        "edgar/daily-index/2017/QTR1/master.20170310.idx",
        "edgar/daily-index/2017/QTR1/master.20170311.idx"
      ]
      list = Edgar::IndexList.days([
        Date.parse('2017-03-10'),
        Date.parse('2017-03-11')
      ])
      expect(list.urls).to match_array(expected_list)
    end
  end

  describe ".new" do
    it "should contain passed urls" do
      urls = ['fake1', 'fake2']
      list = Edgar::IndexList.new(['fake1', 'fake2'])
      expect(list.urls).to match_array(urls)
    end
  end
end

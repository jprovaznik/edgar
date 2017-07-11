require 'time'

module Edgar
  # Represents a list of Edgar index files
  class IndexList
    attr_reader :urls

    def self.days_since(since_date)
      urls = (since_date..Date.today).map {|date| self.daily_url(date)}
      self.new(urls)
    end

    def self.days(dates)
      urls = dates.map {|date| self.daily_url(date)}
      self.new(urls)
    end

    def initialize(urls)
      @urls = urls
    end

    def report_list(opts={})
      mutex = Mutex.new
      result = []

      Downloader.fetch(urls: @urls) do |response|
        idx = Index.new(response.body, opts)
        mutex.synchronize do
          result += idx.report_list
        end
      end

      result
    end

    private

    def self.daily_url(date)
      qtr = (date.month.to_f / 3).ceil
      dstr = date.strftime('%Y%m%d')
      "edgar/daily-index/#{date.year}/QTR#{qtr}/master.#{dstr}.idx"
    end
  end
end

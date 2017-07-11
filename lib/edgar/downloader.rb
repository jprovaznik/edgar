require 'typhoeus'

module Edgar
  # Handles concurrent fetching of reports from Edgar
  class Downloader
    # edgar limit is 10 requests per second per user
    CONCURRENCY = 10
    MIN_DELAY = 0.15

    def self.fetch(opts, &block)
      Downloader.new(opts.merge(block: block)).run
    end

    def initialize(opts = {})
      @urls = opts[:urls] || []
      @callback = opts[:block]
      @hydra = Typhoeus::Hydra.new(max_concurrency: CONCURRENCY)
      @last_request_time = Time.now.to_f
      @semaphore = Mutex.new
    end

    def run
      @urls.map do |url|
        abs_url = File.join(Edgar::BASE_URL, url)
        request = Typhoeus::Request.new(abs_url, followlocation: true)
        @hydra.queue(request)
        request.on_complete do |response|
          Edgar.logger.debug "processing #{response.request.base_url}"
          set_last_request_time
          @callback.call(response)
          wait_for_time_limit
        end
      end
      @hydra.run
    end

    def set_last_request_time
      @semaphore.synchronize do
        @last_request_time = Time.now.to_f
      end
    end

    def wait_for_time_limit
      from_last = @semaphore.synchronize {Time.now.to_f - @last_request_time}
      if from_last < MIN_DELAY
        sleep(MIN_DELAY - from_last)
      end
    end
  end
end

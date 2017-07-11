require 'edgar/index'
require 'edgar/index_list'
require 'edgar/exceptions'
require 'edgar/downloader'
require 'edgar/report'
require 'edgar/index_report_info'
require 'edgar/report_parser/abstract_parser'
require 'edgar/report_parser/form4'
require 'edgar/report_parser/form13f'

module Edgar
  BASE_URL = 'http://www.sec.gov/Archives'.freeze

  class << self
    attr_writer :logger

    def logger
      @logger ||= Logger.new(STDERR).tap do |log|
        log.progname = self.name
        log.level = Logger::DEBUG
      end
    end
  end
end

module Edgar
  # Represents an Edgar report (form4, form 13f...)
  class Report
    attr_reader :uri, :xml

    def self.multi_get(list, &block)
      Array == list || list = Array(list)

      Downloader.fetch(urls: list) do |response|
        if response.code != 200
          Edgar.logger.error "Failed to fetch url '#{response.request.base_url}'"
          next
        end
        yield(Report.new(xml: response.body, uri: response.request.base_url))
      end
    end

    def initialize(opts = {})
      @xml = opts[:xml]
      @uri = opts[:uri]
    end

    def parse
      header = parse_header_info
      @filename = header[:filename]
      @form_type = header[:form_type]
      @parser = get_parser(@form_type)

      {
        uri: @uri,
        filename: @filename,
        fill_date: header[:fill_date],
        basename: File.basename(@filename),
        form_type: @form_type,
        xml_data: @parser.parse(@xml)
      }
    end

    def get_parser(form_type)
      case form_type
      when '4' then ReportParser::Form4.new
      when '13F-HR' then ReportParser::Form13f.new
      when '13F-HR/A' then ReportParser::Form13f.new
      # when '3' then Form3.new(opts)
      else
        raise ReportUnknownType,
              "Failed to get parser for form type '#{form_type}'"
      end
    end

    private

    def parse_header_info
      hmatch = @xml.match(/(.*?)<XML>/m) || raise(ReportHeaderParseError,
                                                  'Report header not found')

      header = hmatch[0]
      res = {}
      header.match(/<SEC-DOCUMENT>([^\s]*) : (\d*)/) do |match|
        res[:filename] = match[1]
        res[:fill_date] = Date.parse(match[2])
      end
      header.match(/<TYPE>([A-Z0-9\/\-]*)/) do |match|
        res[:form_type] = match[1]
      end

      res
    end
  end
end

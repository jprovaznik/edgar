module Edgar
  module ReportParser
    # Basic report parser class
    class AbstractParser
      def parse_date(date)
        m, d, y = date.split('-')
        Date.parse("#{y}-#{m}-#{d}")
      end

      def get_text(doc, path)
        doc.xpath(path).text.strip
      end
    end
  end
end

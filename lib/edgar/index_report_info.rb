module Edgar
  # Represents a single record/row in Edgar index file
  class IndexReportInfo
    attr_reader :cik, :company, :form_type, :filename, :basename

    def initialize(opts = {})
      @cik = opts[:cik]
      @company = opts[:company]
      @form_type = opts[:form_type]
      @basename = opts[:basename]
      @filename = opts[:filename]
    end
  end
end

module Edgar
  # Represents Edgar index file
  class Index

    attr_reader :report_list

    def initialize(data, opts={})
      @accepted_form_types = opts[:accepted_form_types]
      @report_list = parse(data)
    end

    private

    def parse(data)
      data.split("\n").map do |line|
        cik, company, form_type, _date_field, fname = line.split('|')
        next unless fname
        if @accepted_form_types
          @accepted_form_types.include?(form_type) || next
        end
        Edgar::IndexReportInfo.new(
          cik:        normalize_cik(cik),
          company:    company,
          form_type:  form_type,
          basename:   File.basename(fname),
          filename:   fname
        )
      end.compact
    end

    def normalize_cik(cik)
      if cik.length < 10
        '0' * (10 - cik.length) + cik
      else
        cik
      end
    end
  end
end

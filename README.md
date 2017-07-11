# Edgar library

Edgar is a library for concurrent downloading and parsing Edgar reports.

## Installation

```
bundle install
```

## Usage

```
require 'edgar'

# get list of index files from last two days
index_list = Edgar::IndexList.days_since(Date.today-1)

# get list of reports of specific types from these index files
reports = index_list.report_list(accepted_form_types: ['4', '13F-HR'])

# fetch (concurrently) these reports
Edgar::Report.multi_get(reports.map(&:filename)) do |report|
  # parse each report
  begin
    parsed = report.parse
    puts "parsed #{parsed[:uri]}"
  rescue Exception => e
    puts "error: #{e.message}"
  end
end

```

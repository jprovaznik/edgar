require 'date'
require 'nokogiri'

module Edgar
  module ReportParser
    # 13F form parser
    class Form13f < AbstractParser
      attr_reader :errors
      DEBUG = false

      SHARE_TYPES = {
        'SH' => 0,
        'PRN' => 1,
        'PUT' => 2,
        'CALL' => 3
      }.freeze

      DISCRETION = {
        'SOLE' => 0,
        'DEFINED' => 1,
        'DFND' => 1,
        'OTHER' => 2,
        'OTR' => 2
      }.freeze

      def parse(data)
        res = submission(data)
        res[:recs] = info_table(data)
        res
      end

      def submission(data)
        # edgar report is not a valid XML, find the submission part and parse
        # it separately
        chunk = data.match(
          %r{<edgarSubmission.*</edgarSubmission>}m
        )[0]
        xml = Nokogiri::XML(chunk)
        doc = xml.xpath('/xmlns:edgarSubmission')

        res = cover_page(doc.xpath('//xmlns:coverPage'))
        res.merge(summary_page(doc.xpath('//xmlns:summaryPage')))
        res.merge(signature(doc.xpath('//xmlns:signatureBlock')))
        res.merge(header(doc.xpath('//xmlns:headerData')))
        res
      end

      def header(doc)
        {
          form_type: get_text(doc, '//xmlns:submissionType'),
          cik: get_text(doc, '//xmlns:credentials/xmlns:cik')
        }
      end

      def signature(doc)
        {
          fill_date: parse_date(get_text(doc, '//xmlns:signatureDate'))
        }
      end

      def cover_page(doc)
        {
          quarter: parse_date(get_text(doc,
                                       '//xmlns:reportCalendarOrQuarter')),
          amendment_type: get_text(doc, '//xmlns:amendmentType'),
          amendment_number: get_text(doc, '//xmlns:amendmentNo').to_i,
          company: get_text(doc, '/xmlns:filingManager/xmlns:name'),
          address: {
            street1: get_text(doc, '//com:street1'),
            street2: get_text(doc, '//com:street2'),
            city: get_text(doc, '//com:city'),
            state: get_text(doc, '//com:stateOrCountry'),
            zip: get_text(doc, '//com:zipCode')
          }
        }
      end

      def summary_page(doc)
        {
          total_value: get_text(doc, '/xmlns:tableValueTotal').to_i * 1000,
          total_entries: get_text(doc, '/xmlns:tableEntryTotal').to_i
        }
      end

      def info_table(data)
        itable = data.match(
          %r{<([ns1]+:)?informationTable.*</([ns1]+:)?informationTable>}m
        )[0]
        doc = Nokogiri::XML(itable)
        ns = 'http://www.sec.gov/edgar/document/thirteenf/informationtable'

        doc.xpath('//ns:infoTable', 'ns' => ns).map do |node|
          info_table_rec(node)
        end
      end

      def info_table_rec(node)
        ns = 'http://www.sec.gov/edgar/document/thirteenf/informationtable'
        {
          name: node.xpath('ns:nameOfIssuer', 'ns' => ns).text.strip,
          cusip: node.xpath('ns:cusip', 'ns' => ns).text.strip,
          shares_value: node.xpath('ns:value',
                                   'ns' => ns).text.strip.to_i * 1000,
          shares_amount: node.xpath('ns:shrsOrPrnAmt/ns:sshPrnamt',
                                    'ns' => ns).text.strip.to_i,
          shares_type: share_type(node),
          discretion: discretion(node)
        }.merge(voting(node))
      end

      def share_type(node)
        ns = 'http://www.sec.gov/edgar/document/thirteenf/informationtable'
        share_type = node.xpath('ns:shrsOrPrnAmt/ns:sshPrnamtType',
                                'ns' => ns).text.strip
        SHARE_TYPES[share_type]
      end

      def discretion(node)
        ns = 'http://www.sec.gov/edgar/document/thirteenf/informationtable'
        discretion = node.xpath('ns:investmentDiscretion',
                                'ns' => ns).text.strip
        DISCRETION[discretion]
      end

      def voting(node)
        ns = 'http://www.sec.gov/edgar/document/thirteenf/informationtable'
        {
          voting_sole: node.xpath('ns:votingAuthority/ns:Sole',
                                  'ns' => ns).text.strip.to_i,
          voting_shared: node.xpath('ns:votingAuthority/ns:Shared',
                                    'ns' => ns).text.strip.to_i,
          voting_none: node.xpath('ns:votingAuthority/ns:None',
                                  'ns' => ns).text.strip.to_i
        }
      end
    end
  end
end

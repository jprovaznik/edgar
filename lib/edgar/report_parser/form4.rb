require 'date'
require 'nokogiri'

module Edgar
  module ReportParser
    # Form 4 parser
    class Form4 < AbstractParser
      FORM_TYPE = '4'.freeze

      def parse(data)
        # Form4 is not a valid XML, parse only specific chunks
        xml_chunks = data.scan(
          %r{<ownershipDocument.*</ownershipDocument>}m
        ).join
        doc = Nokogiri::XML(xml_chunks)

        {
          form_type: FORM_TYPE,
          issuer: issuer(doc.xpath('/ownershipDocument/issuer')),
          owner: owner(doc.xpath('/ownershipDocument/reportingOwner')),
          non_derivative: non_derivative(
            doc.xpath('/ownershipDocument/nonDerivativeTable')
          )
        }
      end

      def issuer(doc)
        {
          cik: get_text(doc, 'issuerCik'),
          name: get_text(doc, 'issuerName'),
          symbol: get_text(doc, 'issuerTradingSymbol').upcase
        }
      end

      def owner(doc)
        {
          cik: get_text(doc, 'reportingOwnerId/rptOwnerCik'),
          name: get_text(doc, 'reportingOwnerId/rptOwnerName'),
          relationship: relationship(
            doc.xpath('reportingOwnerRelationship')
          )
        }
      end

      def relationship(doc)
        if get_text(doc, 'isDirector') == '1'
          :director
        elsif get_text(doc, 'isTenPercentOwner') == '1'
          :tenpercent
        elsif get_text(doc, 'isOfficer') == '1'
          :officer
        else
          :other
        end
      end

      def non_derivative(doc)
        doc.xpath('nonDerivativeTransaction').map do |trans|
          {
            title: get_text(trans, 'securityTitle'),
            date: parse_date(get_text(trans, 'transactionDate/value')),
            code: get_text(
              trans,
              'transactionCoding/transactionCode'
            ),
            shares: get_text(
              trans,
              'transactionAmounts/transactionShares'
            ).to_i,
            price: get_text(
              trans,
              'transactionAmounts/transactionPricePerShare'
            ).to_i,
            # A = acquired, D = disposed
            action: get_text(
              trans,
              'transactionAmounts/transactionAcquiredDisposedCode'
            ),
            remaining_shares: get_text(
              trans,
              'postTransactionAmounts/sharesOwnedFollowingTransaction/value'
            ).to_i
          }
        end
      end
    end
  end
end

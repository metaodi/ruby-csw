require 'curb'
require 'cgi'

module RCSW
  module Client
    class Base
      def initialize(csw_url, output_schema="http://www.opengis.net/cat/csw/2.0.2")
        @csw_url = csw_url
        @limit = 100
        @output_schema = output_schema
      end
      
      def records
        RCSW::Client::GetRecords.new(@csw_url, @output_schema)
      end
      
      def record(ids=[])
        RCSW::Client::GetRecordById.new(@csw_url, ids, @output_schema)
      end
      
      def capabilities
        RCSW::Client::Capabilities.new(@csw_url)
      end      
    end
  end
end
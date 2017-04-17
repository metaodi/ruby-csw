module RCSW
  module Client
    class GetRecords < Operation
      def initialize(csw_url, output_schema)
        @output_schema = output_schema
        super(csw_url)
      end

      def reload!
        @records = nil
        @request_params = nil
      end
      
      def supported?
        super('GetRecords')
      end
      
      def all
        @records ||= self.execute
      end
      
      def execute
        raise "GetRecords not supported by target CSW" unless self.supported?
        
        results = []

        while records = self.fetch_records 
          results += records.records
        end

        results
      end
      
      def fetch_records
        @per_page ||= 100
        @request_params ||= {
          'startPosition' => 1,
          'maxRecords' => @per_page,
          'resultType' => 'results',
          'ElementSetName' => 'full',
          'outputFormat' => 'application/xml',
          'typeNames' => 'csw:Record',
          'outputSchema' => @output_schema
        }
        
        format = RCSW::Records::Base.new
        request_url = self.build_url(@csw_url, 'GetRecords', capabilities.version, @request_params)

        puts request_url
        
        request = format.read(Curl.get(request_url).body_str)
        
        return false if request.records.nil? or request.records.empty?
        
        @request_params.merge!({ 'startPosition' => request.status.next_record })        
        request
      end
      
      def count
        if @records.nil?
          format = RCSW::Records::Base.new
          request_url = self.build_url(@csw_url, 'GetRecords', capabilities.version)
          request = format.read(Curl.get(request_url).body_str)
          request.status.total
        else
          @records.count
        end
      end
    end
  end
end
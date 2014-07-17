module Cedilla
  
  class Request
    attr_accessor :requestor_ip, :requestor_affiliation, :requestor_language 
    attr_accessor :unmapped, :original_request
    
    attr_accessor :referres, :api_ver, :id, :time
    
    attr_accessor :citation 
    
    # ---------------------------------------------------------------------------------
    def initialize(params = {})
      @api_ver = params['api_ver'] || ''
      @id = params['id'] || ''
      @time = params['time'] || Time.new
      
      @requestor_ip = params['requestor_ip'] || ''
      @requestor_affiliation = params['requestor_affiliation'] || ''
      @requestor_language = params['requestor_language'] || 'en'
      
      @unmapped = params['unmapped'] || ''
      @original_request = params['original_request'] || ''
      
      @referrers = []
      params['referrers'].each{ |referer| @referrers << referer } unless params['referrers'].nil?
            
      @citation = Cedilla::Citation.new(params['citation']) unless params['citation'].nil?
    end
    
  end
  
end
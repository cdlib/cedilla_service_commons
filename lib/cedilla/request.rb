module Cedilla
  
  class Request
    attr_accessor :requestor_ip, :requestor_affiliation, :requestor_language 
    attr_accessor :unmapped, :original_request
    
    attr_accessor :referrers, :api_ver, :id, :time
    
    attr_accessor :citation 
    
    # ---------------------------------------------------------------------------------
    def initialize(params)
      if params.is_a?(Hash)
        @api_ver = params[:api_ver] || ''
        @id = params[:id] || ''
        @time = params[:time] || Time.new
      
        @requestor_ip = params[:requestor_ip] || ''
        @requestor_affiliation = params[:requestor_affiliation] || ''
        @requestor_language = params[:requestor_language] || 'en'
      
        @unmapped = params[:unmapped] || ''
        @original_request = params[:original_request] || ''
      
        @referrers = []
        params[:referrers].each{ |referer| @referrers << referer } unless params[:referrers].nil?
            
            
        if params[:citation].is_a?(Cedilla::Citation)
          @citation = params[:citation]
      
        elsif params[:citation].is_a?(Hash)
          @citation = Cedilla::Citation.new(params[:citation])
      
        else
          @citation = Cedilla::Citation.new({})
        end
        
      else
        raise Error.new("You must supply an attribute hash!")
      end
    end
    
  end
  
end
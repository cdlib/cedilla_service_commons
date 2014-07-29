require 'json'
require 'uri'
require 'net/http'

require_relative './cedilla/error.rb'
require_relative './cedilla/author.rb'
require_relative './cedilla/citation.rb'
require_relative './cedilla/request.rb'
require_relative './cedilla/resource.rb'
require_relative './cedilla/translator.rb'

class CedillaController
  # -------------------------------------------------------------------------
  # Currently expecting API version 1.1 of the Cedilla JSON API
  #   https://github.com/cdlib/cedilla/wiki/JSON-Data-Model:-Between-Aggregator-and-Services
  # 
  # --------------------------------------
  # {"time":"2014-06-30T23:11:11.706Z",
  #  "id":"undefined",
  #  "api_ver":"1.1",
  #  "requestor_ip":"127.0.0.1",
  #  "requestor_affiliation": "CAMPUS-A",
  #  "requestor_language": "en",
  #  "referrers": ["google.com", "domain.org"],
  #  "unmapped":"CALLING_SYSTEM=CDLSFX&xxx=yyy&sid=UCLinks-CSA:georef-set-c:2.40&pid=institute=UCOP&testing_for=holdings&testing_id=331",
  #  "original_request":"CALLING_SYSTEM=CDLSFX&xxx=yyy&sid=UCLinks-CSA:georef-set-c:2.40&volume=2&aulast=Basso&atitle=Geologia del settore ...",
  #  "citation":{"authors":[{"last_name":"Basso","initials":"C","first_name":"C"}],
  #              "volume":"2",
  #              "article_title":"Geologia del settore Irpino-Dauno dell'Appennino Meridionale; unita Meso-Cenozoiche e vincoli stratigrafici ...",
  #              "start_page":"7",
  #              "issn":"0392-0631",
  #              "genre":"article",
  #              "end_page":"1",
  #              "title":"Studi Geologici Camerti",
  #              "year":"2002",
  #              "publisher":"Edimond, Citta di Castello, Italy (ITA)",
  #              "content_type":"full_text"}
  # }
  # -------------------------------------------------------------------------
  
  def handle_request(request, response, service)
    headers = {'Content-Type' => 'text/json',
               'Referer' => request.referrer.nil? ? '' : request.referrer }
    #service = SfxService.new
    
    request.body.rewind  # Just a safety in case its already been read
  
    begin  
      data = request.body.read
      json = JSON.parse(data)
      
      # Capture the ID passed in by the caller because we need to send it back to them
      id = json['id']
    
      unless id.nil?
        LOGGER.info "Received request for id: #{id}"
        LOGGER.debug data 
      
        req = Cedilla::Translator.from_cedilla_json(data)
        
        req.requestor_ip = request.ip if req.requestor_ip.nil?
      
        begin
          if !service.validate_citation(req.citation)
            # No ISBN or ISSN was passed, which this service requires so just send back a 404 Not Found
            LOGGER.info "Request did not contain enough info to contact enpoint for id: #{id}"
            response.status = 404  
            response.body = Cedilla::Translator.to_cedilla_json(id, Cedilla::Citation.new({}))
          
          else
            new_citation = service.process_request(req, headers)
          
            out = Cedilla::Translator.to_cedilla_json(id, new_citation)
          
            # Safety check, if the citations portion is empty return a 404!
            response.status = (out.include?('"citations":[{}]') ? 404 : 200)
            
            response.body = out
            
            LOGGER.info "Response received from endpoint for id: #{id}"
          end
        
        rescue Exception => e
          # Errors at this level should return a 500 level error
          response.status = 500
        
          if e.is_a?(Cedilla::Error)
            # No logging here because the service itself should have written out to the log
            response.body = Cedilla::Translator.to_cedilla_json(id, e)
          else
            LOGGER.error "Error for id: #{id} --> #{e.message}"
            LOGGER.error "#{e.backtrace}"
          
            response.body = Cedilla::Translator.to_cedilla_json(id, Cedilla::Error.new(Cedilla::Error::LEVELS[:error], "An error occurred while processing the request."))
          end
        end
      
      else
        LOGGER.error "The JSON received was invalid! No id was found in JSON."
        LOGGER.error data
        response.status = 400
      end
      
    rescue Exception => e
      # JSON parse exception should throw an invalid request!
      request.body.rewind
      
      LOGGER.error "Error --> #{e.message}"
      LOGGER.error "Request --> #{request.body.read}"
      LOGGER.error "#{e.backtrace}"
      response.status = 400
    end
    
    response
  end
end
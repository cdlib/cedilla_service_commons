module Cedilla
  
  class Service
    
    attr_accessor :translator, :attempts, :redirects
    attr_reader :response_status, :response_headers, :response_body
    attr_reader :target, :query_string, :max_attempts, :http_method, :http_timeout, :http_max_redirects, :http_error_on_non_200, :http_cookies

    # -------------------------------------------------------------------------
    def initialize(config)
      @translator = Cedilla::Translator.new
    
      @attempts = 0
      @redirects = 0
    
      @response_status = 500
      @response_headers = {}
      @response_body = ''
    
      unless config.nil?
        @target = config['target']
        @query_string = config['query_string']
      
        @max_attempts = config['max_attempts'].nil? ? 1 : config['max_attempts'].is_a?(String) ? config['max_attempts'].to_i : config['max_attempts']

        @http_method = config['http_method'].nil? ? 'get' : config['http_method'].downcase
        @http_timeout = config['http_timeout'].nil? ? 5 : config['http_timeout'].is_a?(String) ? config['http_timeout'].to_i : config['http_timeout']
        @http_max_redirects = config['http_max_redirects'].nil? ? 8 : config['http_max_redirects'].is_a?(String) ? config['http_max_redirects'].to_i : config['http_max_redirects']
        @http_error_on_non_200 = config['http_error_on_non_200'].nil? ? true : config['http_error_on_non_200'].is_a?(String) ? config['http_error_on_non_200'] == 'true' : config['http_error_on_non_200'] 
        @http_cookies = config['http_cookies']
      
        @min_api_version = config['minimum_api_version'].nil? ? 1.0 : (config['minimum_api_version'].is_a?(String) ? config['minimum_api_version'].to_f : config['minimum_api_version'])
      
        @config = config
      else
        raise Exception.new("You must supply a configuration hash!")
      end
    end
  
    # -------------------------------------------------------------------------
    def build_form_data(citation)
      hash = citation.to_hash
    
      out = Array.new
      hash_to_form_data_recursive(hash, out) if hash.is_a?(Hash)
      data = out.empty? ? "" : out.join('<br />')
    end
  
    # -------------------------------------------------------------------------
    def add_citation_to_target(citation)
      out = build_target
      query = @translator.hash_to_query_string(citation.to_hash)
      "#{out}#{(out.include?('?') ? (out[-1] == '?' ? "#{query}" : "&#{query}") : "?#{query}")}"
    end
  
    # -------------------------------------------------------------------------
    def process_response
      hdrs = ""
      @response_headers.each{ |k,v| hdrs += "#{k} => #{v}, " }
    
      "HTTP Status: #{@response_status.to_s}\n" +
      "HTTP Headers: #{hdrs}\n" +
      "HTTP Body: #{@response_body.to_s}"
    end
  
    # -------------------------------------------------------------------------
    def process_request(request, headers)
      @attempts += 1
    
      @request = request
    
      # Check the API version
      if @min_api_version >= request.api_ver.to_f
    
        # Add the citation info to the query string
        target = (@http_method == 'get' ? self.add_citation_to_target(request.citation) : build_target)
    
        # Call the target
        begin  
          unless target.nil? or target.strip == ''
            response = call_target(request.citation, target, headers, 0)
          end
    
        rescue => e
          if @attempts < @max_attempts.to_i
            begin
              self.process_request(request, headers)
            rescue => e
              raise
            end
      
          else
            @response_status = response.code.to_i unless response.nil?
            response.header.each_header{ |key,val| @response_headers["#{key.to_s}"] = val.to_s } unless response.nil?
            @response_body = response.body.to_s unless response.nil?
        
            raise
          end
        end
    
        unless response.nil?
          # Set the response objects
          @response_status = response.code.to_i
          @response_headers = {}
          response.each_header.map{ |key,val| @response_headers["#{key.to_s}"] = val.to_s }
          @response_body = response.body.to_s
      
          # Mark the call as an error unless a 2xx status was received
          if @http_error_on_non_200 and ['0', '1', '4', '5', '6', '7', '8', '9'].include?(response.code[0])
            if @attempts < @max_attempts.to_i
              begin
                self.process_request(request, headers)
              rescue => e
                raise
              end
            else
              raise Exception.new("Received a #{response.code} from the target!") 
            end
          end
      
          # Process the results
          return self.process_response
      
        else
          raise Exception.new("Unable to contact the target!")
        end
    
      else
        raise Exception.new("#{self.class} cannot work with JSON data from an API below version #{@min_api_version}")
      end
    end
  
  
  private
    # -------------------------------------------------------------------------
    def build_target
      out = "#{@target}"
      out += "#{(out.include?('?') ? (out[-1] == '?' ? "#{@query_string}" : "&#{@query_string}") : "?#{@query_string}") unless @query_string.nil?}"
      out = (['?', '&'].include?(out[-1]) ? out[0..out.size - 2] : out)
      out.gsub(' ', '%20')
      out
    end
  
    # -------------------------------------------------------------------------
    def call_target(citation, target, headers, redirect)
    
      # TODO: transform citation (and its authors) into an appropriate request for 
      #       the services endpoint (e.g. HTTP GET with citation info in the query string)
      url = URI.parse(target)
    
      #puts "calling: #{target}"
    
      headers = {} unless headers.is_a?(Hash)
      headers[:Cookie] = @http_cookies unless @http_cookies.nil?
    
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true if url.scheme == 'https'
    
      response = http.start do |http|
        http.open_timeout = @http_timeout
        http.read_timeout = @http_timeout
      
        puts url.request_uri
        puts headers.inspect
      
        case @http_method.downcase
        when 'get'
          http.get(url.request_uri, headers) 
      
        when 'patch'
          http.patch(url.request_uri, build_form_data(citation), headers)
      
        else
          http.post(url.request_uri, build_form_data(citation), headers)
        end
      
      end
    
      # Deal with redirects from the service endpoint
      if response.code.to_i >= 300 and response.code.to_i < 400 and @redirects < @http_max_redirects
        @redirects += 1
      
        # Sometimes the redirect location comes back as a fully qualified uri, sometimes just the path!
        if 0 == (response['location'].to_s =~ /http[s]?:\/\//)
          new_target = response['location']
        else
          new_target = "#{url.scheme}://#{url.host}#{url.port.nil? ? '' : ":#{url.port}"}#{response['location']}"
        end
      
        response = call_target(citation, new_target, headers, redirect + 1)
      end
    
      response
    end
  
    # -------------------------------------------------------------------------
    def hash_to_form_data_recursive(hash, out)
      hash.map{ |k,v| v.is_a?(Array) ? v.each { |item| hash_to_form_data_recursive(item, out) } : out << "<input type='hidden' id='#{k}' name='#{k}' value='#{v.to_s}' />" } if hash.is_a?(Hash)
    end
    
  end
  
end
module Cedilla
  
  class Translator
   
    # -----------------------------------------------------------------------------------------------------------------
    def Translator.from_cedilla_json(json)
      req = nil
      
      begin
        hash = JSON.parse(json)

        req = Cedilla::Request.new(convert_string_keys_to_symbols(hash)) unless hash['citation'].nil?
                       
      rescue Exception => e
        $stdout.puts("Exception transforming JSON to entities! #{e.message}")
        $stdout.puts("   json in: #{json}")
        $stdout.puts(e.backtrace)
        
        throw(e)
      end
      
      req
    end
    
    # -----------------------------------------------------------------------------------------------------------------
    def Translator.to_cedilla_json(id, entity)
      begin
        map = {:time => Time.now, :id => id}
        
        if entity.is_a?(Hash)
          entity.each do |key, val|
            
            if val.is_a?(Array)
              map[:"#{key.to_s.downcase}"] = []
              
              val.each do |item|
                map[:"#{key.to_s.downcase}"] << item.to_hash
              end
              
            else
              map[:"#{key.to_s.downcase}"] = [val.to_hash]
            end
          end
          
        else
          map[:"#{entity.class.to_s.downcase.sub('cedilla::', '')}s"] = [entity.to_hash]
        end
        
        JSON.generate(map)
                       
      rescue Exception => e
        $stdout.puts("Exception transforming entity to JSON! #{e.message}")
        $stdout.puts("   values: #{entity.to_hash.collect{ |k,v| "#{k}=#{v}" }.join(', ')}")
        $stdout.puts(e.backtrace)
        
        throw(e)
      end
    end
   
    # -----------------------------------------------------------------------------------------------------------------
    def Translator.hash_to_query_string(hash)
      out = Array.new
      hash_to_query_string_recursive(hash, out) if hash.is_a?(Hash)
      query_string = out.empty? ? "" : out.join('&')
    end
    
# -----------------------------------------------------------------------------------------------------------------
  private 
    def Translator.hash_to_query_string_recursive(hash, out)
      hash.map{ |k,v| v.is_a?(Array) ? v.each { |item| hash_to_query_string_recursive(item, out) } : out << "#{URI.escape(k)}=#{URI.escape(v.to_s)}" } if hash.is_a?(Hash)
    end
  
    # ------------------------------------------------------------------
    def Translator.convert_string_keys_to_symbols(hash)
      ret = {}
      
      hash.each do |k,v|
        if k.is_a?(String)
          if v.is_a?(Hash)
            ret[k.to_sym] =  convert_string_keys_to_symbols(v)
            
          elsif v.is_a?(Array)
            arr = []
            v.each do |item|
              if item.is_a?(Hash)
                arr << convert_string_keys_to_symbols(item)
              else
                arr << item
              end
            end
            ret[k.to_sym] = arr
          else
            ret[k.to_sym] = v
          end
        end
      end
      
      ret
    end
  end
  
end
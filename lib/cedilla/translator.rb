module Cedilla
  
  class Translator
   
    # -----------------------------------------------------------------------------------------------------------------
    def Translator.from_cedilla_json(json)
      begin
        hash = JSON.parse(json)
        
        citation = Cedilla::Citation.new(hash['citation']) unless hash['citation'].nil?
                       
      rescue Exception => e
        $stdout.puts("Exception transforming JSON to entities! #{e.message}")
        $stdout.puts("   json in: #{json}")
        $stdout.puts(e.backtrace)
        
        throw(e)
      end
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
    def hash_to_query_string_recursive(hash, out)
      hash.map{ |k,v| v.is_a?(Array) ? v.each { |item| hash_to_query_string_recursive(item, out) } : out << "#{URI.escape(k)}=#{URI.escape(v.to_s)}" } if hash.is_a?(Hash)
    end
  end
  
end
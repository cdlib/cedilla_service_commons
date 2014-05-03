module Cedilla
  
  class Translator
   
    # -----------------------------------------------------------------------------------------------------------------
    def from_cedilla_json(json)
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
    def to_cedilla_json(service_name, entity)
      begin
        JSON.generate({:time => Time.now, 
                       :service => service_name,
                       :"#{entity.class.to_s.downcase.sub('cedilla::', '')}" => entity.to_hash})
                       
      rescue Exception => e
        $stdout.puts("Exception transforming entity to JSON! #{e.message}")
        $stdout.puts("   values: #{entity.to_hash.collect{ |k,v| "#{k}=#{v}" }.join(', ')}")
        $stdout.puts(e.backtrace)
        
        throw(e)
      end
    end
   
    # -----------------------------------------------------------------------------------------------------------------
    def hash_to_query_string(hash)
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
module Cedilla
  
  class Resource
    FORMATS = {:electronic => 0, :print => 1, :microform => 2, :audio => 3, :video => 4, :export => 5, :extra => 6}
    
    attr_accessor :source, :location, :target
    
    attr_accessor :local_title, :local_id, :format, :type, :description, :catalog_target, :language, :license, :charset
    
    attr_accessor :availability, :status
    
    attr_accessor :rating  # Can be used by the client for sorting purposes the highest score should be at the top
    
    # The others attribute is meant to store undefined citation parameters that came in from the client
    attr_accessor :extras

# --------------------------------------------------------------------------------------------------------------------    
    def initialize(params)
      if params.is_a?(Hash)
        @extras = {}
        @format = FORMATS[:electronic]
      
        # Assign the appropriate params to their attributes, place everything else in others
        params.each do |key,val|
          key = key.id2name if key.is_a?(Symbol)
        
          if self.respond_to?("#{key}=")
            self.method("#{key}=").call(val)
          else
            if self.extras["#{key}"].nil?
              self.extras["#{key}"] = []
            end
          
            self.extras["#{key}"] << val
          end
        end
      
        @availability = false if @availability.nil?
        
      else
        raise Error.new("You must supply an attribute hash!")
      end
    end
    
# --------------------------------------------------------------------------------------------------------------------    
# Establish the primary key for the object: source + location + target
# --------------------------------------------------------------------------------------------------------------------    
    def ==(object)
      if object.is_a?(self.class)
        
        if !@target.nil? and !object.target.nil?
          return @target == object.target  
          
        elsif !@catalog_target.nil? and !object.catalog_target.nil?
          return @catalog_target == object.catalog_target
          
        elsif !@source.nil? and !object.source.nil? and !@location.nil? and !object.location.nil? and !@local_id.nil? and !object.local_id.nil?
          return (@source == object.source and @location == object.location and @local_id == object.local_id)
          
        else
          return false
        end
        
      else
        return false
      end
    end
  
# --------------------------------------------------------------------------------------------------------------------
# If the resource has a target or catalog_target AND there are no errors
# --------------------------------------------------------------------------------------------------------------------  
    def valid?
      !@target.nil? or !@catalog_target.nil? or !@local_id.nil?
    end
    
# --------------------------------------------------------------------------------------------------------------------
    def availability=(val)
      @availability = !!val == val ? val : false
    end

# --------------------------------------------------------------------------------------------------------------------
    def format=(val)
      if val.is_a?(Integer) or val.is_a?(Float)
        @format = FORMATS.find{ |k,v| v == val }.nil? ? FORMATS[:electronic] : val
        
      elsif val.is_a?(Symbol)
        @format = FORMATS[val].nil? ? FORMATS[:electronic] : FORMATS[val]
        
      else
        @format = FORMATS[val.to_sym].nil? ? FORMATS[:electronic] : FORMATS[val.to_sym]
      end
    end
    
# --------------------------------------------------------------------------------------------------------------------
    def format
      FORMATS.find{|k,v| v == @format }[0].id2name
    end
    
# --------------------------------------------------------------------------------------------------------------------
    def to_s
      ret = ""
      
      if !@target.nil?
        ret = "#{@target}"
        
      elsif !@catalog_target.nil?
        ret = "#{@catalog_target}"
        
      else
        ret = @source.to_s
        ret += (ret.length > 0 ? " - #{@location}" : "#{@location}") unless @location.nil?
        ret += (ret.length > 0 ? " - #{@local_id}" : "#{@local_id}") unless @local_id.nil?
      end
      
      ret
    end
    
# --------------------------------------------------------------------------------------------------------------------
    def to_hash
      ret = {}
      
      self.methods.select{ |it| it.id2name[-1] == '=' and !['==', '!='].include?(it.id2name) }.each do |method|
        name = method.id2name.gsub('=', '')
        
        if method.id2name[-1] == '=' and self.respond_to?(name)  
          val = self.method(name).call 
          ret["#{name}"] = val unless val.nil? or ['!', 'others'].include?(name)
        end
      end
      
      ret = ret.merge(@extras)
      
      ret
    end
    
  end
end
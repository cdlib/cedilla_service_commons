module Cedilla
  
  class Resource
    FORMATS = {:electronic => 0, :print => 1, :microform => 2, :audio => 3, :video => 4, :export => 5, :extra => 6}
    
    attr_accessor :source, :location, :target
    
    attr_accessor :local_title, :local_id, :format, :type, :description, :catalog_target, :language, :license, :charset
    
    attr_accessor :availability, :status
    
    attr_accessor :rating  # Can be used by the client for sorting purposes the highest score should be at the top
    
    # The others attribute is meant to store undefined citation parameters that came in from the client
    attr_accessor :others

# --------------------------------------------------------------------------------------------------------------------    
    def initialize(params = {})
      @others = {}
      
      # Assign the appropriate params to their attributes, place everything else in others
      params.each do |key,val|
        key = key.id2name if key.is_a?(Symbol)
        
        if self.respond_to?("#{key}=")
          self.method("#{key}=").call(val)
        else
          @others[key]=val
        end
      end
      
      @availability = false if @availability.nil?
    end
    
# --------------------------------------------------------------------------------------------------------------------    
# Establish the primary key for the object: source + location + target
# --------------------------------------------------------------------------------------------------------------------    
    def ==(object)
      if object.is_a?(self.class)
        return (@source == object.source) && (@location == object.location) && (@target == object.target)
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
    def to_s
      "source: '#{@source}', location: '#{@location}', target: '#{@target}'"
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
      
      ret = ret.merge(@others)
      
      ret
    end
    
  end
end
module Cedilla
  
  class Resource
    FORMATS = {:electronic => 0, :print => 1, :microform => 2, :audio => 3, :video => 4, :export => 5, :extra => 6}
    
    attr_accessor :source, :location, :target
    
    attr_accessor :local_title, :local_id, :format, :type, :description, :catalog_target, :language, :license, :charset
    
    attr_accessor :availability, :status
    
    attr_accessor :rating  # Can be used by the client for sorting purposes the highest score should be at the top
    
    # The others attribute is meant to store undefined citation parameters that came in from the client
    attr_accessor :others, :errors

# --------------------------------------------------------------------------------------------------------------------    
    def initialize(params = {})
      @others = {}
      @errors = {}
      
      # Assign the appropriate params to their attributes, place everything else in others
      params.each do |key,val|
        key = key.id2name if key.is_a?(Symbol)
        
        if self.respond_to?("#{key}=")
          self.method("#{key}=").call(val)
        else
          @others << "#{key}=#{val}"
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
# If the resoource has a target or catalog_target AND there are no errors
# --------------------------------------------------------------------------------------------------------------------  
    def valid?
      (!@target.nil? or !@catalog_target.nil? or !@local_id.nil?) and @errors.empty?
    end      
    
# --------------------------------------------------------------------------------------------------------------------
    def target=(val)
      CedillaValidation.valid_url?(val) ? @errors.delete(:target) : @errors[:target] = InvalidURLError.new
      @target = val
    end
  
# --------------------------------------------------------------------------------------------------------------------
    def catalog_target=(val)
      CedillaValidation.valid_url?(val) ? @errors.delete(:catalog_target) : @errors[:catalog_target] = InvalidURLError.new
      @catalog_target = val
    end
  
# --------------------------------------------------------------------------------------------------------------------
    def availability=(val)
      !!val == val ? @errors.delete(:availability) : @errors[:availability] = InvalidBooleanError.new
      @availability = val
    end

# --------------------------------------------------------------------------------------------------------------------  
    def format=(val) 
      FORMATS[:"#{val}"].nil? and FORMATS.select{ |x,y| y == val }.empty? ? @errors[:format] = InvalidResourceFormatError.new : 
                                                                            @errors.delete(:format)
      @format = val
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
          ret["#{name}"] = val unless val.nil? or ['!', 'errors', 'others'].include?(name)
        end
      end
      
      @others.each{ |item| parts = item.split('='); ret["#{parts[0]}"] = "#{parts[1]}" }

      ret
    end

  end
end
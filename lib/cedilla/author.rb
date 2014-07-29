module Cedilla
  
  class Author
    # Author attributes
    attr_accessor :corporate_author 
    attr_accessor :full_name, :last_name, :first_name, :suffix
    attr_accessor :middle_initial, :first_initial, :initials 
    attr_accessor :dates, :authority
    
    attr_accessor :extras
    
# --------------------------------------------------------------------------------------------------------------------    
    def initialize(params)
      if params.is_a?(Hash)
        @extras = {}
      
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
        
      else
        raise Error.new("You must supply an attribute hash!")
      end
    end

# --------------------------------------------------------------------------------------------------------------------    
    def self.from_abritrary_string(value)
      params = {}
      
      params[:dates] = value.slice(/[0-9\-]+/) unless value.slice(/[0-9\-]+/).nil?
      
      # Last Name, First Name Initial
      if 0 == (value =~ /[a-zA-Z\s\-]+,\s?[a-zA-Z\s\-]+\s[a-zA-Z]{1}\.?/)
        params[:last_name] = value.slice(/[a-zA-Z\s\-]+,/).gsub(',', '')
        params[:middle_initial] = value.slice(/[a-zA-Z]{1}\./)
        params[:first_name] = value.gsub("#{params[:last_name]}, ", '').gsub(" #{params[:middle_initial]}", '')
        
      # Last Name, Initial Initial
      elsif 0 == (value =~ /[a-zA-Z\s\-]+,\s?[a-zA-Z]{1}\.?\s[a-zA-Z]{1}\.?/)
        params[:last_name] = value.slice(/[a-zA-Z\s\-]+,/).gsub(',', '')
        inits = value.split('.')
        inits.each do |init|
          params[:middle_initial] = "#{inits[1].gsub(' ', '')}." unless inits[1].include?(params[:last_name])
          params[:first_initial] = "#{inits[0].gsub(' ', '').gsub(',', '').gsub(params[:last_name], '')}." if inits[0].include?(params[:last_name])
        end
        
      # Initial Initial Last Name
      elsif 0 == (value =~ /[a-zA-Z]{1}\.?\s+[a-zA-Z]{1}\.?\s+[a-zA-Z\s\-]+/)
        inits = value.split('.')
        params[:first_initial] = "#{inits[0].gsub(' ', '')}."
        params[:middle_initial] = "#{inits[1].gsub(' ', '')}."
        params[:last_name] = "#{inits[2].gsub(' ', '')}"
        
      # First Name Initial Last Name
      elsif 0 == (value =~ /[a-zA-Z\s\-]+\s+[a-zA-Z]{1}\.?\s+[a-zA-Z\s\-]+/)
        inits = value.split('.')
        params[:middle_initial] = "#{inits[0][-1]}."
        params[:first_name] = "#{inits[0][0..inits[0].size - 3]}"
        params[:last_name] = "#{inits[1]}"
        
      # Last Name, First Name
      elsif 0 == (value =~ /[a-zA-Z\s\-]+,\s?[a-zA-Z\s\-]+/)
        names = value.split(', ')
        params[:last_name] = names[0]
        params[:first_name] = names[1]
        
      # First Name Last Name
      elsif 0 == (value =~ /[a-zA-Z\s\-]+\s+[a-zA-Z\s\-]+/)
        names = value.gsub('  ', ' ').split(' ')
        params[:first_name] = names[0..(names.size / 2) - 1].join(' ')
        params[:last_name] = names[(names.size / 2)..names.size].join(' ')
        
      else
        params[:last_name] = value
      end
        
      self.new(params)
    end

# --------------------------------------------------------------------------------------------------------------------    
    def ==(object)
      return false unless object.is_a?(self.class)
    
      ret = @full_name == object.full_name
      ret = (@last_name == object.last_name and (@first_name == object.first_name or @first_initial == object.first_initial)) unless ret or @last_name.nil?
      ret = @corporate_author = object.corporate_author unless ret or @corporate_author.nil?
      
      ret
    end

# --------------------------------------------------------------------------------------------------------------------    
    def last_name_first
      if @last_name.nil?
        if @first_name.nil? and @first_initial.nil?
          @corporate_author
        else
          "#{@first_name.nil? ? @first_initial : @first_name} #{@middle_initial}".strip
        end
        
      else
        if @first_name.nil? and @first_initial.nil?
          @last_name
        else
          "#{@last_name}, #{@first_name.nil? ? @first_initial : @first_name} #{@middle_initial}".strip
        end
      end
    end

# --------------------------------------------------------------------------------------------------------------------    
    def first_name=(val)
      @first_name = val.strip
      @first_initial = "#{val[0].gsub(' ', '').upcase}."
      
      @initials = "#{@first_initial} #{@middle_initial}".strip
    end

# --------------------------------------------------------------------------------------------------------------------        
    def first_initial=(val)
      @first_initial = val.strip
      
      @first_name = @first_initial if @first_name.nil?
      
      @initials = "#{@first_initial} #{@middle_initial.nil? ? '' : @middle_initial}".strip
    end
        
# --------------------------------------------------------------------------------------------------------------------        
    def middle_initial=(val)
      @middle_initial = val.strip
      
      @initials = "#{@first_initial.nil? ? '' : "#{@first_initial} "}#{@middle_initial}"
    end
    
# --------------------------------------------------------------------------------------------------------------------    
    def initials=(val)
      @initials = val.strip
      
      inits = val.split('. ')
      @first_initial = "#{inits[0]}." if @first_name.nil?
      @middle_initial = inits[1]
    end

# --------------------------------------------------------------------------------------------------------------------          
    def last_name=(val)
      @last_name = val.strip
    end

# --------------------------------------------------------------------------------------------------------------------          
    def full_name=(val)
      auth = Cedilla::Author.from_abritrary_string(val)
      
      @dates = auth.dates unless auth.dates.nil?
      
      @first_name = auth.first_name unless auth.first_name.nil?
      @last_name = auth.last_name unless auth.last_name.nil?
      @middle_initial = auth.middle_initial unless auth.middle_initial.nil?
      @first_initial = auth.first_initial unless auth.first_initial.nil?
      @intials = auth.initials unless auth.initials.nil?
    end

# --------------------------------------------------------------------------------------------------------------------          
    def full_name
      if @full_name.nil? 
        if @corporate_author.nil?
          "#{@first_name.nil? ? @first_initial : @first_name} #{@middle_initial} #{@last_name}".gsub('  ', ' ').strip 
        else
          @corporate_author
        end
      else
        @full_name
      end
    end
      
# --------------------------------------------------------------------------------------------------------------------    
    def to_s
      "author: '#{@full_name}"
    end
    
# --------------------------------------------------------------------------------------------------------------------
    def to_hash
      ret = {}
      
      self.methods.each do |method|
        name = method.id2name.gsub('=', '')
        val = self.method(name).call if method.id2name[-1] == '=' and self.respond_to?(name)  
        ret["#{name}"] = val unless val.nil? or ['!', 'others'].include?(name)
      end
      
      ret = ret.merge(@extras)
      
      ret
    end
  end
  
end
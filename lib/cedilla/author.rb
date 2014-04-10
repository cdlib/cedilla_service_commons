module Cedilla
  
  class Author
    # Author attributes
    attr_accessor :name, :corporate_author, :full_name, :last_name, :first_name, :suffix
    attr_accessor :middle_initial, :first_initial, :initials 
    attr_accessor :dates
    
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
          @others << "#{key}=#{val}"
        end
      end
    end

# --------------------------------------------------------------------------------------------------------------------    
    def self.from_abritrary_string(value)
      params = {}
      
      params[:dates] = value.slice(/[0-9\-]+/) unless value.slice(/[0-9\-]+/).nil?
      
      # Last Name, First Name Initial
      if 0 == (value =~ /[a-zA-Z\s\-]+,\s?[a-zA-Z\s\-]+\s[a-zA-Z]{1}\./)
        params[:last_name] = value.slice(/[a-zA-Z\s\-]+,/).gsub(',', '')
        params[:middle_initial] = value.slice(/[a-zA-Z]{1}\./)
        params[:first_name] = value.gsub("#{params[:last_name]}, ", '').gsub(" #{params[:middle_initial]}", '')
        
      # Last Name, Initial Initial
      elsif 0 == (value =~ /[a-zA-Z\s\-]+,\s?[a-zA-Z]{1}\.\s[a-zA-Z]{1}\./)
        params[:last_name] = value.slice(/[a-zA-Z\s\-]+,/).gsub(',', '')
        inits = value.split('.')
        inits.each do |init|
          params[:middle_initial] = "#{init.gsub(' ', '')}." unless init.include?(params[:last_name])
          params[:first_initial] = "#{init.gsub(' ', '').gsub(',', '').gsub(params[:last_name], '')}." if init.include?(params[:last_name])
        end
        
      # Initial Initial Last Name
      elsif 0 == (value =~ /[a-zA-Z]{1}\.\s+[a-zA-Z]{1}\.\s+[a-zA-Z\s\-]+/)
        inits = value.split('.')
        params[:first_initial] = "#{init[0].gsub(' ', '')}."
        params[:middle_initial] = "#{init[1].gsub(' ', '')}."
        params[:last_name] = "#{init[2].gsub(' ', '')}"
        
      # First Name Initial Last Name
      elsif 0 == (value =~ /[a-zA-Z\s\-]+\s+[a-zA-Z]{1}\.\s+[a-zA-Z\s\-]+/)
        inits = value.split('.')
        params[:middle_initial] = "#{init[0][-1]}."
        params[:first_name] = "#{init[0][0..init[0].size - 1]}"
        params[:last_name] = "#{init[1]}"
        
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
        params[:name] = value
      end
        
      self.new(params)
    end

# --------------------------------------------------------------------------------------------------------------------    
    def ==(object)
      return false unless object.is_a?(self.class)
    
      ret = @full_name == object.full_name
      ret = @name == object.name unless ret or @name.nil?
      ret = @corporate_author = object.corporate_author unless ret or @corporate_author.nil?
      
      ret
    end

# --------------------------------------------------------------------------------------------------------------------    
    def last_name_first
      "#{@last_name}#{@first_name.nil? ? @first_initial.nil? ? '' : ", #{@first_initial}" : ", #{@first_name}"}"
    end

# --------------------------------------------------------------------------------------------------------------------    
    def first_name=(val)
      @first_name = val
      @first_initial = "#{val[0].gsub(' ', '').upcase}."
      
      @initials = "#{@first_initial} #{@middle_initial}".strip
      @full_name = "#{@first_name}#{@middle_initial.nil? ? '' : " #{@middle_initial}"} #{@last_name}".gsub('  ', ' ')
    end

# --------------------------------------------------------------------------------------------------------------------        
    def first_initial=(val)
      @first_initial = val
      
      @initials = "#{@first_initial}#{@middle_initial.nil? ? '' : @middle_initial}".strip
      @full_name = "#{@first_name.nil? ? @first_initial : @first_name}#{@middle_initial.nil? ? '' : " #{@middle_initial}"} #{@last_name}".gsub('  ', ' ')
    end
        
# --------------------------------------------------------------------------------------------------------------------        
    def middle_initial=(val)
      @middle_initial = val
      
      @initials = "#{@first_initial.nil? ? '' : "#{@first_initial} "}#{@middle_initial}"
      @full_name = "#{@first_name.nil? ? @first_initial : @first_name} #{@middle_initial} #{@last_name}".gsub('  ', ' ')
    end
    
# --------------------------------------------------------------------------------------------------------------------    
    def initials=(val)
      @initials = val
      
      inits = val.split('. ')
      @first_initial = "#{inits[0]}." if @first_name.nil?
      @middle_initial = inits[1]
      @full_name = "#{@first_name.nil? ? @first_initial : @first_name} #{@middle_initial} #{@last_name}".gsub('  ', ' ')
    end

# --------------------------------------------------------------------------------------------------------------------          
    def last_name=(val)
      @last_name = val
      @full_name = "#{@first_name.nil? ? @first_initial : @first_name} #{@middle_initial} #{@last_name}".gsub('  ', ' ')
    end

# --------------------------------------------------------------------------------------------------------------------          
    def full_name
      @full_name.strip.strip unless @full_name.nil?
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
      
      @others.each{ |item| parts = item.split('='); ret["#{parts[0]}"] = "#{parts[1]}" }
      
      ret
    end
  end
  
end
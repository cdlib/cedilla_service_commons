module Cedilla
  
  class Error < Exception
    LEVELS = {:fatal => 0, :error => 1, :warning => 2}
    
    LVLS = {:fatal => ['fatal'], 
              :error => ['error'], 
              :warning => ['warn', 'warning', 'debug', 'info']}
    
    attr_accessor :message, :level
    
    # ----------------------------------------------------------------
    def initialize(level, message)
      self.level = level
      @message = message.to_s
    end
    
    # ----------------------------------------------------------------
    def to_hash
      level = LEVELS.select{ |key, val| val = @level }.nil? ? 'error' : LEVELS.select{ |key, val| val = @level }.first
        
      {"level" => self.level, "message" => @message}
    end
  
    # ----------------------------------------------------------------
    def to_s
      "#{self.level}: #{@message}"
    end
  
    # ----------------------------------------------------------------
    def level
      return LEVELS.find{ |k,v| v == @level }[0].to_s
    end
    
    # ----------------------------------------------------------------
    def level=(val)
      if val.is_a?(Integer) or val.is_a?(Float)
        @level = LEVELS.find{ |k,v| v == val }.nil? ? LEVELS[:error] : val
        
      elsif val.is_a?(Symbol)
        @level = LEVELS[val].nil? ? LEVELS[:error] : LEVELS[val]
        
      else
        @level = LVLS.find{ |k,v| v.include?(val) }.nil? ? LEVELS[:error] : LEVELS[LVLS.find{|k,v| v.include?(val) }[0]]
      end
    end
    
  end
  
end
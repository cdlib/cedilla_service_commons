module Cedilla
  
  class Error
    LEVELS = {:fatal => 0, :error => 1, :warning => 2}
    
    attr_accessor :message, :level
    
    def initialize(level, message)
      @level = LEVELS[level].nil? ? LEVELS[:error] : LEVELS[level]
      @message = message
    end
    
    def to_hash
      level = LEVELS.select{ |key, val| val = @level }.nil? ? 'error' : LEVELS.select{ |key, val| val = @level }.first
        
      {"level" => level, "message" => @message}
    end
    
  end
  
end
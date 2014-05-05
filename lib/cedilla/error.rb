module Cedilla
  
  class Error
    LEVELS = {:fatal => 0, :error => 1, :warning => 2}
    
    attr_accessor :message, :level
    
  end
  
end
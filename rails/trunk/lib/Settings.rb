require 'singleton'
require 'yaml'

class Settings
    include Singleton
    attr_reader :config
    
    def initialize()
        load 
    end
   
    def load
        @config = YAML::load(ERB.new(IO.read(Rails.root.join('config', 'config.yml'))).result)[Rails.env]
    end
    
    def self.[](key) 
        #Rails.logger.info("Looking up setting for key " + PP.pp(key,"") + " = " + PP.pp(instance.config[key],""))
        return instance.config[key]
    end
end
  

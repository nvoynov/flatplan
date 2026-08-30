require_relative '../medium'
require_relative '../config'

module Flatplan
  module Command
    
    # Base command class
    class Base
      def initialize; end
      def config = Config.instance
      protected :config
    end
  end
end

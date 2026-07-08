require_relative 'store'
require_relative 'version'

module Negatives

  # Command-line Interface
  module CLI
    extend self

    BANNER = <<~TEXT.strip
      Negatives metadata store
      Version #{VERSION}

      Usage:       
        bin/negatives <image_1> [<image_2> ..]
    TEXT

    # TODO: make version and banner files
    def call
      if ARGV.empty?
        puts BANNER
        exit
      end

      store = Store.new
      data  =
        if ARGV.size > 1
          store
            .slice(*ARGV)
            .values
            .map(&:to_h)
        else
          store
            .get(ARGV.shift)
            .to_h
        end

      puts JSON.pretty_generate(data)
    end

  end
end

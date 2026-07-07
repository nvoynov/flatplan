require_relative 'store'

module PhotoStore

  module CLI
    extend self

    # TODO: make version and banner files
    def call
      if ARGV.empty?
        puts <<~BANNER.strip
          Metadata Store v0.1.0
          Usage:
            photostore <image_1> [<image_2> ..]
        BANNER

        exit
      end

      store = Store.new
      data  =
        if ARGV.size > 1
          store
            .slice(*ARGV)
            .values
            # .tap{ puts "bin/photostore values"; pp it}
            .map(&:to_h)
            # .tap{ pp it }
        else
          store
            .get(ARGV.shift)
            .to_h
        end

      puts JSON.pretty_generate(data)
    end

  end
end

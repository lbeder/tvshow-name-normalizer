require 'lib/tvshow'

module TVShowNameNormalizer
  class Engine
    def initialize(options)
      @options = options
    end

    def normalize(path:)
      path = File.expand_path(path) if path
      raise ArgumentError, "#{path} isn't a file or doesn't exist!" unless File.file?(path)

      tvshow = TVShow.from_path(path)
      raise "#{path} is invalid!" unless tvshow.valid?

      dest = [File.join(File.dirname(path), tvshow.to_s), File.extname(path)].join
      puts "Normalizing:\n \t#{path} to\n \t#{dest}"

      FileUtils.mv(path, dest) if path != dest
    end
  end
end

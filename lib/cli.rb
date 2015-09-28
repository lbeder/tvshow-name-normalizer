require 'thor'
require 'lib/engine'

module TVShowNameNormalizer
  class CLI < Thor
    include Thor::Actions

    def initialize(*args)
      super(*args)

      @engine = Engine.new(options)
    end

    desc 'normalize', 'normalize tv show file name'
    method_option :path, :type => :string, required: true
    def normalize
      @engine.normalize(path: @options[:path])
    end
  end
end

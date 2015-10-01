require 'thor'
require 'lib/engine'

module TVShowNameNormalizer
  class CLI < Thor
    include Thor::Actions

    def initialize(*args)
      super(*args)

      @engine = Engine.new(options)
    end

    desc 'normalize', 'Normalize tv show file name'
    method_option :path, :type => :string, required: true, desc: 'Path to the file'
    def normalize
      @engine.normalize(path: @options[:path])
    end

    desc 'normalize_directory', 'Normalive tv show file names in a directory'
    method_option :path, :type => :string, required: true, desc: 'Path to the directory'
    method_option :recursive, :type => :boolean, default: false,
      desc: 'Iterate through first level sub-directories'
    def normalize_directory
      @engine.normalize_directory(path: @options[:path], recursive: @options[:recursive])
    end
  end
end

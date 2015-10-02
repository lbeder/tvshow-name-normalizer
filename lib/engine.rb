require 'lib/tvshow'

module TVShowNameNormalizer
  class Engine
    VIDEO_EXTENSIONS = %w(webm mkv flv vob ogv ogg avi mov wmv rm rmvb asf mp4 m4p m4v mpg mp2 mpeg mpe mpv 3gp).freeze

    def initialize(options)
      @options = options
    end

    def normalize(path:)
      path = File.expand_path(path) if path
      return unless self.class.video?(path)

      tvshow = TVShow.from_path(path)
      raise "#{path} is invalid!" unless tvshow.valid?

      [File.join(File.dirname(path), tvshow.to_s), File.extname(path)].join.tap do |dest|
        unless path == dest
          puts "Normalizing:\n \t#{path} to\n \t#{dest}"

          FileUtils.mv(path, dest)
        end
      end
    end

    def normalize_directory(path:, recursive: false, root: true)
      path = File.expand_path(path) if path
      raise ArgumentError, "#{path} isn't a directory or doesn't exist!" unless File.directory?(path)

      # Iterate over existing files (and first level directories, if requested).
      Dir.glob(File.join(self.class.escape_glob(path), '*')).each do |src|
        begin
          if File.file?(src)
            dest = normalize(path: src)
            next unless dest

            # If we're operating in a first level sub-directory - move the file to the root directory and
            # remove the current directory.
            unless root
              pathname = Pathname.new(dest)
              root_dir = pathname.parent.parent

              unless dest == root_dir
                puts "Moving:\n \t#{dest} to\n \t#{root_dir}"

                FileUtils.mv(dest, root_dir)
              end

              FileUtils.rm_r(pathname.parent)
            end
          elsif recursive
            # Iterate over the files in the directory and normalize them.
            normalize_directory(path: src, recursive: false, root: false)
          end
        rescue => e
          puts "Failed processing #{src} with: #{e.message}. Skipping..."
        end
      end
    end

    def self.video?(path)
      File.file?(path) && VIDEO_EXTENSIONS.include?(File.extname(path)[1..-1])
    end

    def self.escape_glob(s)
      s.gsub(/[\\\{\}\[\]\*\?]/) {|x| "\\#{x}"}
    end
  end
end

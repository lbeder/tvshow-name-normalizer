module TVShowNameNormalizer
  class TVShow
    CD_FOLDER_REGEXP = /\/CD(\d)\//.freeze
    SPACE_SUB_REGEXP = /(\.|_|\-)/.freeze
    VIDEO_TYPE_NAMES = %w[DVDRIP 1080p 720p R5 DVDSCR BDRip CAM TS PPV Xvid divx DVDSCREENER].freeze
    CONTENT_SOURCE_FOLDER_TEST_REGEXP = /#{VIDEO_TYPE_NAMES.join('|')}/i.freeze
    CONTENT_SOURCE_REGEXP = /(\(|\[|\s)+(#{VIDEO_TYPE_NAMES.join('|')})(\)|\]|\s|$)+/i.freeze
    LIMITED_REGEXP = /LIMITED|LiMiTED$/.freeze
    SESSION_ESP_REGEXP_1 = /S(\d{2})\s?E(\d{2})/i.freeze
    SESSION_ESP_REGEXP_2 = /\s+(\d+)x(\d+)(\s|$)+/i.freeze
    SESSION_ESP_REGEXP_3 = /Season (\d+) Episode (\d+)/i.freeze
    SESSION_ESP_REGEXP_OF = /(\d+)\s?of\s?(\d+)/i.freeze
    SESSION_REGEXPS = [SESSION_ESP_REGEXP_1, SESSION_ESP_REGEXP_2, SESSION_ESP_REGEXP_3].freeze

    attr_accessor :name, :series, :episode

    def initialize(params)
      self.name = params[:name]
      self.series = params[:series]
      self.episode = params[:episode]
    end

    def valid?
      [name, series, episode].all?(&:present?)
    end

    def to_s
      "#{name} - S#{'%02d' % series}E#{'%02d' % episode}"
    end

    def self.from_path(path)
      raw_name = File.basename(path, File.extname(path))

      # Remove anything at the start of the name surrounded by [], sometimes there is website name url.
      raw_name = raw_name.gsub(/^\[[^\]]+\]/, '')

      # Remove space sub chars.
      raw_name = raw_name.gsub(SPACE_SUB_REGEXP, ' ').strip

      name = raw_name.dup

      # Chop off any info about the movie format or source.
      name = $` if name =~ CONTENT_SOURCE_REGEXP

      # Strip LIMITED off the end.  Note: This is case sensitive.
      name = $` if name =~ LIMITED_REGEXP

      # Try to extract the session and episode
      session = nil
      episode = nil
      SESSION_REGEXPS.each do |session_regexP|
        if name =~ session_regexP
          name = $`
          session = $1.to_i
          episode = $2.to_i
          break
        end
      end

      if session.nil? && name =~ SESSION_ESP_REGEXP_OF
        name = $`
        session = 1
        episode = $1.to_i
      end

      # Sometimes there can be multiple media files for a single movie, we want to remove the version
      # number if this is the case.
      if path =~ CD_FOLDER_REGEXP
        cd_number = $1.to_i
        if name =~ /#{cd_number}$/
          name = $`
        elsif name =~ /part\s?#{cd_number}/i
          name = $`
        end
      end

      name.strip!

      TVShow.new(name: name, series: session, episode: episode)
    end
  end
end

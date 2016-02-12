module TVShowNameNormalizer
  class TVShow
    SPACE_SUB_REGEXP = /(\.|_|\-)/.freeze
    VIDEO_TYPE_NAMES = %w(DVDRIP 1080p 720p R5 DVDSCR BDRip CAM TS PPV Xvid divx DVDSCREENER).freeze
    CONTENT_SOURCE_FOLDER_TEST_REGEXP = /#{VIDEO_TYPE_NAMES.join('|')}/i.freeze
    CONTENT_SOURCE_REGEXP = /(\(|\[|\s)+(#{VIDEO_TYPE_NAMES.join('|')})(\)|\]|\s|$)+/i.freeze
    LIMITED_REGEXP = /LIMITED|LiMiTED$/.freeze
    SESSION_REGEXP_1 = /S(\d{1,2})\s?E(\d{1,2})/i.freeze
    SESSION_REGEXP_2 = /\s+(\d+)x(\d+)(\s|$)+/i.freeze
    SESSION_REGEXP_3 = /Season (\d+) Episode (\d+)/i.freeze
    SESSION_REGEXP_OF = /(\d+)\s?of\s?(\d+)/i.freeze
    SESSION_REGEXP_0 = /\s?(\d+)0(\d+)\s?/i.freeze
    SESSION_REGEXPS = [SESSION_REGEXP_1, SESSION_REGEXP_2, SESSION_REGEXP_3].freeze
    DATE_REGEXP = /(\d{4})[\.|-|_|\s](\d{2})[\.|-|_|\s](\d{2})/i.freeze

    attr_accessor :name, :series, :episode, :date

    def initialize(params)
      self.name = params[:name].titleize
      self.series = params[:series]
      self.episode = params[:episode]
      self.date = params[:date]
    end

    def valid?
      name.present? && (series? || date?)
    end

    def to_s
      if series?
        "#{name} - S#{format('%02d', series)}E#{format('%02d', episode)}"
      elsif date?
        "#{name} - #{date.strftime('%F')}"
      else
        name
      end
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

      # Strip LIMITED off the end. Note: This is case sensitive.
      name = $` if name =~ LIMITED_REGEXP

      # Try to extract the session and episode.
      session = nil
      episode = nil
      SESSION_REGEXPS.each do |session_regexp|
        next unless name =~ session_regexp

        name = $`
        session = Regexp.last_match[1].to_i
        episode = Regexp.last_match[2].to_i
      end

      if session.nil? && name =~ SESSION_REGEXP_OF
        name = $`
        session = 1
        episode = Regexp.last_match[1].to_i
      end

      # Try to extract date.
      if name =~ DATE_REGEXP
        name = $`

        date = DateTime.new(Regexp.last_match[1].to_i, Regexp.last_match[2].to_i, Regexp.last_match[3].to_i)
      else
        date = nil
      end

      if session.nil? && name =~ SESSION_REGEXP_0
        name = $`
        session = Regexp.last_match[1].to_i
        episode = Regexp.last_match[2].to_i
      end

      name.strip!

      TVShow.new(name: name, series: session, episode: episode, date: date)
    end

    private

    def series?
      [series, episode].all?(&:present?)
    end

    def date?
      date.present?
    end
  end
end

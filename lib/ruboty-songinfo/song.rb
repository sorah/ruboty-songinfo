module RubotySonginfo
  class Song
    def initialize(
      name: ,
      artist: [],
      composer: [],
      arranger: [],
      lyricist: [],
      appearances: [],
      released_at: nil,
      released_year: nil,
      lyric: nil,
      provider: nil)

      @name = name
      @artist = artist
      @composer = composer
      @arranger = arranger
      @lyricist = lyricist
      @appearances = appearances
      @released_at = released_at
      @released_year = released_year
      @lyric = lyric
      @provider = provider

      normalize!
    end

    attr_reader(
      :name, :artist,
      :composer, :arranger, :lyricist,
      :appearances,
      :released_at,
      :lyric, :provider,
    )

    def released_year
      released_at ? released_at.year : @released_year
    end

    def contributors
      artist + composer + lyricist
    end

    def normalize!
      normalize_to_arrays
      nil
    end

    private

    def normalize_to_arrays
      %i(@artist @composer @arranger @lyricist).each do |ivar|
        value = instance_variable_get(ivar)
        next unless value

        unless value.kind_of?(Array)
          instance_variable_set(ivar, [value])
        end
      end
    end

  end
end

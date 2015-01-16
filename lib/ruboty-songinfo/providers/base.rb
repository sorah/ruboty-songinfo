module RubotySonginfo
  module Providers
    class Base
      def initialize(config={})
        @config = config
      end

      def show(ref)
      end

      def search(query)
        raise NotImplementedError
      end

      def search_artist(query)
        raise NotImplementedError
      end

      def search_song(query)
        raise NotImplementedError
      end

      def search_appearance(query)
        raise NotImplementedError
      end

      def search_composer(query)
        raise NotImplementedError
      end

      def search_arranger(query)
        raise NotImplementedError
      end

      def search_lyricist(query)
        raise NotImplementedError
      end
    end
  end
end

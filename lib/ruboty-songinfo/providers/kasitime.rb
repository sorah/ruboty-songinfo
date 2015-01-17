require 'ruboty-songinfo/ref'
require 'ruboty-songinfo/search_result'
require 'ruboty-songinfo/song'

require 'ruboty-songinfo/providers/base'

require 'ruboty-songinfo/util/duckduckgo'

require 'cgi/util'
require 'nokogiri'
require 'open-uri'

module RubotySonginfo
  module Providers
    class Kasitime < Base
      SHOW_METHODS = {
        artist: :show_artist,
        song: :show_song,
        appearance: :show_appearance,
        composer: :show_composer,
        arranger: :show_arranger,
        lyricist: :show_lyricist,
      }

      def show(ref)
        raise ArgumentError if ref.provider != self.class

        link = ref.spec[:link]
        type = classify_link(link)

        __send__ SHOW_METHODS[type], link
      end

      def search(query)
        SearchResult.new("query '#{query}'", query_duckduckgo(query))
      end

      def search_artist(query)
        SearchResult.new("artist query '#{query}'",
          query_duckduckgo(query).select do |item|
            item.type == :artist
          end
        )
      end

      def search_song(query)
        SearchResult.new("song query '#{query}'",
          query_duckduckgo(query).select do |item|
            item.type == :song
          end
        )
      end

      def search_appearance(query)
        SearchResult.new("song query '#{query}'",
          query_duckduckgo(query).select do |item|
            item.type == :appearance
          end
        )
      end

      def search_composer(query)
        SearchResult.new("composer query #{query}",
          query_duckduckgo(query).select do |item|
            item.type == :composer
          end
        )
      end

      def search_arranger(query)
        SearchResult.new("arranger query #{query}",
          query_duckduckgo(query).select do |item|
            item.type == :arranger
          end
        )
      end

      def search_lyricist(query)
        SearchResult.new("lyricist query #{query}",
          query_duckduckgo(query).select do |item|
            item.type == :lyricist
          end
        )
      end

      private

      def query_duckduckgo(query)
        Util::Duckduckgo.search("site:kasi-time.com #{query}").select do |link|
          %r{([a-z0-9\-.]+?\.)?kasi-time\.com} === link[:link].host
        end.reject do |link|
          link[:sponsored]
        end.map do |link|
          type = classify_link(link[:link])
          Ref.new(self.class, link[:title], type, link: link[:link])
        end
      end

      def classify_link(link)
        case link.path
        when %r{\A/item-(.+?)\.html\z}
          :song
        when %r{\A/subcat-sakushi-(.+?)\.html\z}
          :lyricist
        when %r{\A/subcat-sakkyoku-(.+?)\.html\z}
          :composer
        when %r{\A/subcat-henkyoku-(.+?)\.html\z}
          :arranger
        when %r{\A/subcat-uta-(.+?)\.html\z}
          :artist
        when %r{\A/subcat-cat-(.+?)\.html\z}
          :appearance
        end
      end

      def show_song(link)
        html = Nokogiri::HTML(open(link, 'r', &:read))
        item_id = link.path.match(/item-(.+?)\.html\z/)[1]

        lyric = open("http://www.kasi-time.com/item_js.php?no=#{URI.encode_www_form_component(item_id)}", 'r', &:read).
          sub(/\A\n*document.write\('/, '').sub(/'\);\z/,'').gsub(/<br>/,"\n").gsub(/&nbsp;/, ' ')
        lyric.force_encoding('utf-8')
        lyric = CGI.unescape_html(lyric)

        Song.new(
          name: html.at('.song_info h1').inner_text,
          artist: html.search('.song_info a[href^="subcat-uta-"]').map { |link|
            Ref.new(self.class, link.inner_text, :artist,
                    link: URI("http://www.kasi-time.com/#{link[:href]}"))
          },
          lyricist: html.search('.song_info a[href^="subcat-sakushi-"]').map { |link|
            Ref.new(self.class, link.inner_text, :lyricist,
                    link: URI("http://www.kasi-time.com/#{link[:href]}"))
          },
          composer: html.search('.song_info a[href^="subcat-sakkyoku-"]').map { |link|
            Ref.new(self.class, link.inner_text, :composer,
                    link: URI("http://www.kasi-time.com/#{link[:href]}"))
          },
          arranger: html.search('.song_info a[href^="subcat-henkyoku-"]').map { |link|
            Ref.new(self.class, link.inner_text, :arranger,
                    link: URI("http://www.kasi-time.com/#{link[:href]}"))
          },
          appearances: html.search('.song_info a[href^="subcat-cat-"]').map { |link|
            Ref.new(self.class, link.inner_text, :appearance,
                    link: URI("http://www.kasi-time.com/#{link[:href]}"))
          },
          lyric: lyric,
          provider: self.class,
        )
      end

      def show_list(link)
        link = URI(link.to_s + "?sort=a&order=d")
        html = Nokogiri::HTML(open(link, 'r', &:read))

        rows = html.search('#resultData tr').to_a
        rows.shift(2)

        SearchResult.new(html.at('.main h1').inner_text,
          rows.map do |row|
            itemlink = row.at('a[href^="item-"]')
            Ref.new(self.class, itemlink.inner_text, :song,
                    link: URI("http://www.kasi-time.com/#{itemlink[:href]}"))
          end
        )
      end

      alias show_artist show_list
      alias show_appearance show_list
      alias show_composer show_list
      alias show_arranger show_list
      alias show_lyricist show_list
    end
  end
end

require 'ruboty-songinfo/providers/kasitime'
require 'ruboty-songinfo/search_result'
require 'ruboty-songinfo/song'

require 'ruboty/handlers/base'


module Ruboty
  module Handlers
    class Songinfo < Base
      on(/songinfo\s+search\s+?(?:page(?:\s+|[=:])(?<page>\d+)\s+)?(?<query>.+)/, name: 'search_all', description: 'search songinfo')
      on(/songinfo\s+show\s+?(?:page(?:\s+|[=:])(?<page>\d+)\s+)?(?<query>.+)/, name: 'show_all', description: 'show songinfo')
      on(/songinfo\s+flush\s+?cache/, name: 'flush', description: 'flush songinfo cache')
      on(/show\s+(?<type>songinfo|song|artist|composer|arranger|lyricist|appearance)\s+?(?:page(?:\s+|[=:])(?<page>\d+)\s+)?(?<query>.+)/, name: 'show', description: 'show songinfo something')
      on(/search\s+(?<type>songinfo|song|artist|composer|arranger|lyricist|appearance)\s+?(?:page(?:\s+|[=:])(?<page>\d+)\s+)?(?<query>.+)/, name: 'search', description: 'search songinfo something')
      on(/lyric\s+of\s+(?<query>.+)/, name: 'lyric', description: 'show lyric for song')

      def search_all(message)
        message.reply query(:search, :all, message[:query], message[:page])
      rescue Exception => e
        message.reply "#{e.inspect}\n\t#{e.backtrace.join("\n\t")}"
      end

      def show_all(message)
        message.reply query(:show, :all, message[:query], message[:page])
      rescue Exception => e
        message.reply "#{e.inspect}\n\t#{e.backtrace.join("\n\t")}"
      end

      def show(message)
        message.reply query(:show, message[:type], message[:query], message[:page])
      rescue Exception => e
        message.reply "#{e.inspect}\n\t#{e.backtrace.join("\n\t")}"
      end

      def search(message)
        message.reply query(:search, message[:type], message[:query], message[:page])
      rescue Exception => e
        message.reply "#{e.inspect}\n\t#{e.backtrace.join("\n\t")}"
      end

      def lyric(message)
        message.reply query(:lyric, :song, message[:query])
      rescue Exception => e
        message.reply "#{e.inspect}\n\t#{e.backtrace.join("\n\t")}"
      end

      def flush_cache
        @cache = {}
        message.reply "Flushed"
      end

      private

      def query(mode, type, query, page = nil)
        meth = case type
        when :all, 'songinfo'
          :search
        else
          :"search_#{type}"
        end
        result = (cache[[meth,query]] ||= provider.__send__(meth, query))

        if result.kind_of?(RubotySonginfo::SearchResult) && (mode == :show || mode == :lyric)
          ref = result.items.first
          if ref
            result = (cache[ref.spec] ||= provider.show(ref))
          else
            result = nil
          end
        end

        format result, show_lyric: mode == :lyric, page: page
      end

      def format(result, show_lyric: false, page: nil)
        page = page && /\A\d+\z/ === page ? [1, page.to_i].max : 1
        case result
        when RubotySonginfo::SearchResult
          lines = ["Search result: #{result.title}", ""]

          range = (items_per_page*(page-1))...(items_per_page*page)
          items = result.items[range]

          if page > 1
            lines << '...'
          end

          lines.push(*items.map {|ref| "- #{ref.title}" })

          if result.items.size > range.end
            lines << '...'
          end

          lines.join("\n")
        when RubotySonginfo::Song
          lines = [
            "Song: #{result.name}",
            "Artist: #{result.artist.map(&:title).join(", ")}",
            "Composed by: #{result.composer.map(&:title).join(", ")}",
            "Arranged by: #{result.arranger.map(&:title).join(", ")}",
            "Lyrics by: #{result.lyricist.map(&:title).join(", ")}",
          ].compact

          if show_lyric
            lines << ''
            lines << result.lyric
          end

          lines.join("\n")
        when nil
          "not found"
        else
          result.inspect
        end

      end

      def cache
        @cache ||= {}
      end

      def provider
        # TODO: multiple providers
        @provider ||= RubotySonginfo::Providers::Kasitime.new
      end

      def items_per_page
        @items_per_page ||= begin
          env = ENV['RUBOTY_SONGINFO_ITEMS_PER_PAGE']
          env ? env.to_i : 10
        end
      end
    end
  end
end

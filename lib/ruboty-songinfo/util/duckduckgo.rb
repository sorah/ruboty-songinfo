require 'open-uri'
require 'nokogiri'
require 'uri'

module RubotySonginfo
  module Util
    module Duckduckgo
      def self.search(query)
        q = URI.encode_www_form_component query
        url = "https://duckduckgo.com/html/?q=#{q}"

        html = Nokogiri::HTML(open(url, 'r', &:read))

        html.search('#links .web-result').map do |elem|
          classes = elem[:class].split(/\s*/)
          link = elem.at('.links_deep a')

          {
            sponsored: classes.include?('web-result-sponsored'),
            title: link.inner_text,
            link: URI.parse(link[:href]),
            snippet: elem.search('.snippet').inner_text,
          }
        end
      end
    end
  end
end

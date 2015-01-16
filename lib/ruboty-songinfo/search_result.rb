
module RubotySonginfo
  class SearchResult
    def initialize(title, items)
      @title, @items = title, items
    end

    attr_reader :title, :items
  end
end

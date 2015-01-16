module RubotySonginfo
  class Ref
    def initialize(provider, title, type, spec)
      @provider, @title, @type, @spec = provider, title, type, spec
    end

    def to_s
      @title || inspect
    end

    def inspect
      "#<RubotySonginfo::Ref: #{provider.name}, #{type}: #{title}>"
    end

    attr_reader :provider, :title, :type, :spec
  end
end

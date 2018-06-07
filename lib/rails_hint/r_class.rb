# frozen_string_literal: true

module RailsHint
  class RClass
    class << self
      def search(path)
        parser = Parsers::ClassParser.new(path).tap(&:parse!)
        parser.classes.map do |type, name, super_name|
          RailsHint.pool[name] ||= new(type, name, super_name, path)
        end.uniq
      end
    end

    def initialize(type, name, super_name, path)
      @type = type
      @name = name
      @super_name = super_name
      @path = path
    end
    attr_reader :type, :name, :super_name, :path
  end
end

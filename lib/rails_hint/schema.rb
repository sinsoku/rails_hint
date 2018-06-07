# frozen_string_literal: true

module RailsHint
  Table = Struct.new(:name, :options, :columns, :indexes, :foreign_keys)
  Column = Struct.new(:type, :name, :options)
  Index = Struct.new(:column_name, :options)
  ForeignKey = Struct.new(:to_table, :options)

  class Schema
    class << self
      def parse(path)
        parser = Parsers::SchemaParser.new(path).tap(&:parse!)
        new(parser.version, parser.tables)
      end
    end

    def initialize(version, tables)
      @version = version
      @tables = tables
    end
    attr_reader :version, :tables
  end
end

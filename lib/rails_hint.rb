# frozen_string_literal: true

require "ripper"
require "rails_hint/parsers/class_parser"
require "rails_hint/parsers/schema_parser"
require "rails_hint/r_class"
require "rails_hint/schema"
require "rails_hint/version"

module RailsHint
  class << self
    def classes
      @classes ||= Dir["**/*.rb"].flat_map { |f| RClass.search(f) }
    end

    def pool
      @pool ||= {}
    end

    def schema_version
      schema.version
    end

    def tables
      schema.tables
    end

    private

    def schema
      @schema ||= Schema.parse("db/schema.rb")
    end
  end
end

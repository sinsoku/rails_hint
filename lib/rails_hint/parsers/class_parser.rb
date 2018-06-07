# frozen_string_literal: true

module RailsHint
  module Parsers
    class ClassParser
      def initialize(path)
        @path = path
        @classes = []
      end
      attr_reader :classes

      def parse!
        body = File.read(path)
        sexp = Ripper.sexp(body, path)
        walk(sexp, [])
      end

      private

      attr_reader :path

      def walk(node, ancestors)
        type = node[0]
        m = :"on_#{type}"
        send(m, node, ancestors) if private_methods.include?(m)

        node.each do |n|
          next unless n.is_a?(Array)

          new_ancestors = [node] + ancestors
          walk(n, new_ancestors)
        end
      end

      def on_class(node, ancestors)
        on_class_or_module(node, ancestors)
      end

      def on_module(node, ancestors)
        on_class_or_module(node, ancestors)
      end

      def on_class_or_module(node, ancestors)
        type = node[0]
        children = node.drop(1)

        namespaces = extra_namespaces(ancestors)
        const_name = children.dig(0, 1, 1)
        name = [namespaces << const_name].join("::")
        super_name = extract_super_name(children[1]) if type == :class

        classes << [type, name, super_name]
      end

      def extra_namespaces(ancestors)
        return [] if ancestors.empty?

        ancestors.select { |n| n.is_a?(Array) && %i[class module].include?(n[0]) }
          .map { |n| n.dig(1, 1, 1) }
          .reverse
      end

      def extract_super_name(node)
        return if node.nil?

        type = node[0]
        children = node.drop(1)

        case type
        when :var_ref, :const_path_ref
          children.map { |n| extract_super_name(n) }
            .join("::")
        when :@const
          children[0]
        end
      end
    end
  end
end

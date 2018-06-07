# frozen_string_literal: true

module RailsHint
  module Parsers
    class SchemaParser
      def initialize(path)
        @path = path
        @version = nil
        @tables = []
      end
      attr_reader :version, :tables

      def parse!
        body = File.read(path)
        sexp = Ripper.sexp(body, path)
        walk(sexp)
      end

      private

      attr_reader :path

      def walk(node)
        type = node[0]
        m = :"on_#{type}"
        send(m, node) if private_methods.include?(m)

        node.each do |n|
          next unless n.is_a?(Array)
          walk(n)
        end
      end

      def on_method_add_arg(node)
        children = node[1..-1]
        call_node = children[0]
        call_children = call_node[1..-1]
        receiver = extract_receiver(call_children[0])
        method_name = call_children.dig(2, 1)
        return if "#{receiver}.#{method_name}" != "ActiveRecord::Schema.define"

        arg_paren = children[1]
        args_add_block = arg_paren[1][1..-1]
        args_node = args_add_block[0]
        args = args_node.map { |n| extract_literal_value(n) }

        @version = args.last[:version]
      end

      def on_command(node)
        children = node[1..-1]
        ident_node = children[0] #=> [:@ident, <method_name:String>, <location:Array>]
        method_name = ident_node[1]

        args_add_block = children[1][1..-1]
        args_node = args_add_block[0]
        args = args_node.map { |n| extract_literal_value(n) }

        case method_name
        when "create_table"
          table_name = args[0]
          options = args[1]
          tables << Table.new(table_name, options, [], [], [])
        when "add_foreign_key"
          table = tables.find { |t| t.name == args[0] }
          table.foreign_keys << ForeignKey.new(args[1], args[2])
        end
      end

      def on_command_call(node)
        children = node[1..-1]

        ident_node = children[2]
        method_name = ident_node[1]

        args_add_block = children[3][1..-1]
        args_node = args_add_block[0]
        args = args_node.map { |n| extract_literal_value(n) }

        table = tables.last
        if method_name == "index"
          table.indexes << Index.new(args[0], args[1])
        else
          table.columns << Column.new(method_name.to_sym, args[0], args[1])
        end
      end

      def extract_receiver(node)
        type = node[0]

        case type
        when :const_path_ref
          children = node[1..-1]
          children.map { |child| extract_receiver(child) }.join("::")
        when :var_ref
          extract_receiver(node[1])
        when :@const
          node[1]
        end
      end

      def extract_literal_value(node)
        type = node[0]

        case type
        when :string_literal
          extract_literal_value(node[1])
        when :string_content
          if node[1]
            extract_literal_value(node[1])
          else
            ""
          end
        when :@tstring_content
          node[1]
        when :symbol_literal
          node.dig(1, 1, 1).to_sym
        when :array
          node[1].map { |n| extract_literal_value(n) }
        when :bare_assoc_hash
          node[1].map { |n| extract_literal_value(n) }.to_h
        when :assoc_new
          node[1..-1].map { |n| extract_literal_value(n) }
        when :@label
          node[1].delete_suffix(":").to_sym
        when :var_ref
          extract_literal_value(node[1])
        when :@int
          node[1].to_i
        when :@float
          node[1].to_f
        when :@kw
          if node[1] == "true"
            true
          elsif node[1] == "false"
            false
          else
            node[1]
          end
        when :hash
          extract_literal_value(node[1])
        when :assoclist_from_args
          n = node.dig(1, 0)
          extract_literal_value(n)
        end
      end
    end
  end
end

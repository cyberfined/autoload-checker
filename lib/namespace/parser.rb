# frozen_string_literal: true

require 'ripper'
require 'namespace'

class Namespace
  class NonRootAstError < StandardError; end
  class ConstRefExpectedError < StandardError; end

  class Parser
    def initialize(file)
      @file = file
    end

    def call
      @ast = File.open(@file) { |fd| Ripper.sexp(fd, @file) }
      raise NonRootAstError, @file unless @ast[0] == :program

      module_or_class_defs(@ast[1])
    end

    private

    def module_or_class_defs(ast)
      ast.each_with_object({}) do |stmt, namespaces|
        next if !stmt.is_a?(Array) || !%i[module class].include?(stmt[0])

        type = stmt[0]
        const_ref = stmt[1]
        raise ConstRefExpectedError unless %i[const_ref const_path_ref].include?(const_ref[0])

        next if const_ref[0] == :const_path_ref

        name = const_ref[1][1]
        pos = const_ref[1][2]
        line = pos[0]
        column = pos[1]

        children = module_or_class_defs(module_or_class_body(stmt))
        namespaces[name] = Namespace.new(
          type: type, name: name, children: children, file: @file, line: line, column: column
        )
      end
    end

    def module_or_class_body(ast)
      index = ast.find_index { |stmt| stmt.is_a?(Array) && stmt[0] == :bodystmt }
      ast[index][1]
    end
  end
end

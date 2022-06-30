# frozen_string_literal: true

require 'pathname'
require 'namespace/fix'
require 'namespace/parser'

class Namespace
  class Validator
    attr_reader :fixes, :namespaces

    def initialize(root_dirs)
      @root_dirs = root_dirs
      @namespaces = {}
      @fixes = Hash.new { |hsh, k| hsh[k] = [] }
    end

    def call
      directories = @root_dirs
      new_directories = []

      while directories.any?
        dir = directories.pop
        Pathname.glob(File.join(dir, '*')) do |file|
          if file.directory?
            new_directories << file
          elsif file.extname == '.rb'
            namespace = Namespace::Parser.new(file.to_s).call
            add_namespace(namespace)
          end
        end

        if directories.empty?
          directories = new_directories
          new_directories = []
        end
      end
    end

    private

    def add_namespace(namespace)
      merge_children(@namespaces, namespace)
    end

    def merge_children(children1, children2)
      children2.each do |k, space2|
        space1 = children1[k]
        if !space1
          if space2.class? && !space2.has_standalone_file? && space2.children.any?
            @fixes[space2.file] << Fix.new(
              file: space2.file, const_name: k, from: :class, to: :module
            )
            space2.type = :module
          end

          children1[k] = space2
          next
        end

        if space1.type != space2.type
          @fixes[space2.file] << Fix.new(
            file: space2.file, const_name: k, from: space2.type, to: space1.type
          )
        end

        merge_children(space1.children, space2.children)
      end
    end
  end
end

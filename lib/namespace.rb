# frozen_string_literal: true

require 'pathname'
require 'namespace/corrector'
require 'namespace/fix'
require 'namespace/parser'
require 'namespace/validator'

class Namespace
  attr_reader :name, :children, :file, :line, :column
  attr_accessor :type

  def initialize(type:, name:, children:, file:, line:, column:)
    @type = type
    @name = name
    @children = children
    @file = file
    @line = line
    @column = column
  end

  def has_standalone_file?
    Pathname.new(@file).basename.to_s == to_snake_case(@name) + ".rb"
  end

  def class?
    @type == :class
  end

  def module?
    @type == :module
  end

  private
  
  def to_snake_case(str)
    str.gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
       .gsub(/([a-z\d])([A-Z])/,'\1_\2')
       .tr('-', '_')
       .downcase
  end
end

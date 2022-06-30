# frozen_string_literal: true

class Namespace
  class Fix
    attr_reader :file, :const_name, :from, :to

    def initialize(file:, const_name:, from:, to:)
      @file = file
      @const_name = const_name
      @from = from
      @to = to
    end

    def pretty_error
      "#{@file}: #{const_name} must be a #{@to} not a #{@from}"
    end
  end
end

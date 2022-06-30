# frozen_string_literal

class Namespace
  class Corrector
    def initialize(file:, fixes:)
      @file = file
      @fixes = fixes
    end

    def call
      content = File.read(@file)
      @fixes.each do |fix|
        content.gsub!(/#{fix.from} #{fix.const_name}/, "#{fix.to} #{fix.const_name}")
      end
      File.write(@file, content)
    end
  end
end

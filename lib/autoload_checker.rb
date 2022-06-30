# frozen_string_literal: true

class AutoloadChecker
  def initialize(path:, correct:, output: $stderr)
    @path = path
    @correct = correct
    @output = output
  end

  def call
    validator.call
    return if fixes.empty?

    if correct?
      fixes.each { |file, fixes| Namespace::Corrector.new(file: file, fixes: fixes).call }
    else
      validator.fixes.each do |_file, fixes|
        fixes.each { |fix| @output.puts(fix.pretty_error) }
      end
    end
  end

  def fixes
    validator.fixes
  end

  private

  def validator
    @validator ||= Namespace::Validator.new(@path)
  end

  def correct?
    @correct
  end
end

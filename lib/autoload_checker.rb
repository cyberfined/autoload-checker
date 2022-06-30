# frozen_string_literal: true

class AutoloadChecker
  def initialize(root_dirs:, correct:, output: $stderr)
    @root_dirs = root_dirs
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
    @validator ||= Namespace::Validator.new(@root_dirs)
  end

  def correct?
    @correct
  end
end

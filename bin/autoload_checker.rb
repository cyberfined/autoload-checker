#!/usr/bin/env ruby

require 'pathname'
$:.unshift Pathname.new(File.expand_path(__dir__)).parent.join('lib')

require 'optparse'
require 'namespace'
require 'autoload_checker'

Options = Struct.new(:dir, :correct)

options = Options.new(nil, false)
opt_parser = OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} [options]"
  opts.on('-p FILE', '--path', String, '[Mandatory] file or directory to check') do |v|
    options.dir = v
  end
  opts.on('-c', '--correct', TrueClass, 'Enable errors correction') { |v| options.correct = v }
  opts.on('-h', '--help', 'Prints this help') do
    puts opts
    exit
  end
end
opt_parser.parse!

unless options.dir
  puts opt_parser.help
  exit(1)
end

autoload_checker = AutoloadChecker.new(path: options.dir, correct: options.correct)
autoload_checker.call
exit(1) if autoload_checker.fixes.any? && !options.correct

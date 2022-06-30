# frozen_string_literal: true

require 'pathname'
$:.unshift Pathname.new(File.expand_path(__dir__)).parent.join('lib')

require 'namespace'
require 'autoload_checker'

def fixtures_root
  Pathname.new(File.expand_path(__dir__)).join('fixtures')
end

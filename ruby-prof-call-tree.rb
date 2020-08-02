# ruby ruby-prof-call-tree.rb
# qcachegrind ruby_prof_reports/callgrind.callgrind.out.6865

require 'ruby-prof'
require_relative 'task-1.rb'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work(disable_gc: true)
end

printer = RubyProf::CallTreePrinter.new(result)
printer.print(path: "ruby_prof_reports", profile: "callgrind")

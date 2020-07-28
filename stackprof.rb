# stackprof stackprof.dump
# stackprof stackprof.dump --method Object#work

require 'stackprof'
require_relative 'task-1.rb'

StackProf.run(mode: :wall, out: 'stackprof_reports/stackprof.dump', interval: 100) do
  work(disable_gc: true)
end

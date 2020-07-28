# stackprof stackprof.dump
# stackprof stackprof.dump --method Object#work

require 'json'
require 'stackprof'
require_relative 'task-1.rb'

result = StackProf.run(mode: :wall, raw: true) do
  work(disable_gc: true)
end

File.write('stackprof_reports/stackprof.json', JSON.generate(result))

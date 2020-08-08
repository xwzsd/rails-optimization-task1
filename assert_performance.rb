# rspec assert_performance.rb

require 'rspec-benchmark'
require_relative 'task-1.rb'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  describe 'linear work' do
    it 'works under 31 ms for size 10k (data_10.txt)' do
      expect {
        work
      }.to perform_under(31).ms.warmup(2).times.sample(10).times
    end
  end
end

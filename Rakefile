# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

namespace :test do
  desc 'Run JavaScript unit tests'
  task :js do
    sh 'node --import ./test/javascript/register.mjs --test test/javascript/*.test.mjs'
  end
end

desc 'Detect duplicate code with Flay'
task :flay do
  output = `bundle exec flay -m 25 lib`
  score = output[/^Total score \(lower is better\) = (\d+)/, 1].to_i
  abort output unless score.zero?
end

task default: :spec

# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'stimulus_table_filter/version'

Gem::Specification.new do |s|
  s.name        = 'stimulus_table_filter'
  s.version     = StimulusTableFilter::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['icoluccio']
  s.email       = ['ignacio.coluccio@gmail.com']
  s.homepage    = 'https://github.com/icoluccio/stimulus-table-filter'
  s.summary     = 'Client-side table filtering, sorting and search for Rails'
  s.description = 'Stimulus controller and view helpers that add instant search, filter ' \
                  'dimensions, multi-column sort, pagination and live footer stats to any ' \
                  'Rails table. Everything is wired through data attributes, with no ' \
                  'JavaScript dependencies or configuration required.'
  s.license     = 'MIT'
  s.required_ruby_version = '>= 3.2'

  s.files = `git ls-files -z`.split("\x0").reject do |f|
    f.start_with?('spec/', 'gemfiles/', '.github/', 'coverage/', '.bundle/') ||
      %w[Appraisals .overcommit.yml .rubocop.yml .gitignore Rakefile].include?(f)
  end
  s.require_paths = ['lib']

  s.add_dependency 'railties', '>= 7.0', '< 9'
end

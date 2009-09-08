require 'rubygems'
require 'rake'
require 'spec/rake/spectask'

Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

task :default => :spec

Spec::Rake::SpecTask.new('rcov') do |rcov|
  rcov.spec_files = FileList['spec/**/*_spec.rb']
  rcov.rcov = true
  rcov.rcov_opts << '--exclude gems/,spec/ --aggregate coverage.data'
end

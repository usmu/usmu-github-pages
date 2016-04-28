lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'rspec/core/rake_task'
require 'usmu/github/pages/version'

def current_gems
  Dir["pkg/usmu-github-pages-#{Usmu::Github::Pages::VERSION}*.gem"]
end

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
end

desc 'Run all test scripts'
task :test => [:clean, :spec, :mutant]

desc 'Run mutation tests'
task :mutant, [:target] => [:clean] do |_, args|
  old = ENV.delete('CODECLIMATE_REPO_TOKEN')
  if `which mutant 2>&1 > /dev/null; echo \$?`.to_i != 0
    puts 'Mutant isn\'t supported on your platform. Please run these tests on MRI <= 2.1.5.'
  else
    sh('bundle', 'exec', 'mutant', '--include', 'lib', '--require', 'usmu/github/pages', '--use', 'rspec', args[:target] || 'Usmu::Github::Pages*')
  end
  ENV['CODECLIMATE_REPO_TOKEN'] = old unless old.nil?
end

desc 'Run CI test suite'
task :ci => [:clean, :spec]

desc 'Clean up after tests'
task :clean do
  [
      'test/coverage',
      current_gems,
  ].flatten.each do |f|
    rm_r f if File.exist? f
  end
end

namespace :gem do
  desc 'Build gems'
  task :build => [:clean] do
    mkdir 'pkg' unless File.exist? 'pkg'
    Dir['*.gemspec'].each do |gemspec|
      sh "gem build #{gemspec}"
    end
    Dir['*.gem'].each do |gem|
      mv gem, "pkg/#{gem}"
    end
  end

  desc 'Install gem'
  task :install => ['gem:build'] do
    sh "gem install pkg/usmu-github-pages-#{Usmu::Github::Pages::VERSION}.gem"
  end

  desc 'Deploy gems to rubygems'
  task :deploy => ['gem:build'] do
    current_gems.each do |gem|
      sh "gem push #{gem}"
    end
    sh "git tag #{Usmu::Github::Pages::VERSION}" if File.exist? '.git'
  end
end

# (mostly) borrowed from: https://gist.github.com/mcansky/802396
desc 'generate changelog with nice clean output'
task :changelog, :since_c, :until_c do |_, args|
  since_c = args[:since_c] || `git tag | egrep '^[0-9]+\\.[0-9]+\\.[0-9]+\$' | sort -Vr | head -n 1`.chomp
  until_c = args[:until_c]
  cmd=`git log --pretty="format:%ci::::%an <%ae>::::%s::::%H" #{since_c}..#{until_c}`

  entries = Hash.new
  changelog_content = "\#\# #{Usmu::Github::Pages::VERSION}\n\n"

  cmd.lines.each do |entry|
    _date, author, subject, hash = entry.chomp.split('::::')
    entries[author] = Array.new unless entries[author]
    entries[author] << "#{subject} (#{hash})" unless subject =~ /Merge/
  end

  # generate clean output
  entries.keys.each do |author|
    changelog_content += author + "\n\n"
    entries[author].reverse_each { |entry| changelog_content += "* #{entry}\n" }
  end

  puts changelog_content
end

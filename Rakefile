$: << "#{File.dirname __FILE__}/lib"

gem = :lucid_async

require "#{gem}/version"

task :build do
  system "gem build #{gem}.gemspec"
end

task :release => :build do
  system "gem push #{gem}-#{LucidAsync::VERSION}.gem"
end

task :install => :build do
  system "gem install #{gem}-#{LucidAsync::VERSION}.gem"
end

task :clean do
  system "rm #{gem}-*.gem"
end

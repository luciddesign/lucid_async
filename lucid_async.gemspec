$: << "#{File.dirname __FILE__}/lib"

require 'lucid_async/version'

Gem::Specification.new do |s|

  s.name                   = 'lucid_async'
  s.summary                = 'Asynchronous programming library.'
  s.description            = 'Convenient interface for safe asynchronous programming.'
  s.license                = 'MIT'

  s.version                = LucidAsync::VERSION

  s.author                 = 'Kelsey Judson'
  s.email                  = 'kelsey@luciddesign.co.nz'
  s.homepage               = 'http://github.com/luciddesign/lucid_async'

  s.files                  = %w{ README.md LICENSE lib/lucid_async.rb } +
                             Dir.glob( 'lib/lucid_async/**/*' )

  s.platform               = Gem::Platform::RUBY
  s.has_rdoc               = false

  s.required_ruby_version  = '>= 2.0.0'

end

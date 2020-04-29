Gem::Specification.new { |s|
  s.name        = 'imap-helper'
  s.version     = '1.0.1'
  s.date        = '2020-04-29'
  s.summary     = "#{s.name} library"
  s.description = "My #{s.name} library"
  s.authors     = ["chaos0x8"]
  s.files       = Dir['lib/**/*.rb', 'bin/*.rb']
  s.executables = Dir['bin/*'].select { |x| File.executable?(x) }.collect { |x| File.basename(x) }
  s.add_dependency 'mail', '~> 2.7', '>= 2.7.1'
}


#!/usr/bin/env ruby

autoload :FileUtils, 'fileutils'

require 'rake/testtask'

Rake::TestTask.new(:test) { |t|
  t.pattern = "#{File.dirname(__FILE__)}/test/**/Test*.rb"
}

desc "#{File.basename(File.dirname(__FILE__))}"
task(:default => :test)

desc 'build gem file'
task(:gem => 'this.gemspec') {
  sh 'gem build this.gemspec'
  Dir['*.gem'].sort{ |a, b| File.mtime(a) <=> File.mtime(b) }[0..-2].each { |fn|
    FileUtils.rm(fn, verbose: true)
  }
}

desc 'update bulk include file'
file('lib/imap-helper.rb' => FileList['lib/imap-helper/*.rb']) { |t|
  d = []
  d << "#!/usr/bin/env/ruby"
  d << ""
  t.sources.each { |r|
    d << "require_relative 'imap-helper/#{File.basename(r)}'"
  }
  d << ""

  IO.write(t.name, d.join("\n"))
}

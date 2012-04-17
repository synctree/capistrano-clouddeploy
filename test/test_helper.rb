require 'rubygems'
require "bundler/setup"
#require 'bundler'
#Bundler.setup
gem 'test-unit'

%w[ test/unit test/spec mocha ].each { |f|
  begin
    require f
  rescue LoadError
    abort "Unable to load required gem for test: #{f}"
  end
}

require File.dirname(__FILE__) + '/../lib/capistrano-clouddeploy/aws_manager'





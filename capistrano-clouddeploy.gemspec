# -*- encoding: utf-8 -*-
require File.expand_path('../lib/capistrano-clouddeploy/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "capistrano-clouddeploy"
  gem.version       = CapistranoCloudDeploy::VERSION
  gem.authors         = ["Masahji Stewart", "Royce Rollins"]
  gem.email           = ["masahji@synctree.com", "royce@synctree.com"]
  gem.homepage        = "http://github.com/synctree/capistrano-clouddeploy"
  gem.summary         = "Cloud Deployment and configuration for Amazon EC2"
  gem.description = "A Ruby library for capturing deployment configuration info from ec2 and future cloud services"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

end

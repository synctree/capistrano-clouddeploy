# Capistrano::Clouddeploy

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'capistrano-clouddeploy'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capistrano-clouddeploy

## Usage
within deploy.rb:
require 'capistrano-clouddeploy'
cloud_config_roles = [ :db_host, :phpmyadmin_endpoint, :redis_host ]
cloud_required_roles = [ :jobs, :app, :web, :db, :delayed_workers, :resque, :resque_tweetmyjobs, :resque_all ]
set :deploy_manager, CapistranoDeployManager::AWS.new(self, application, stage)
deploy_manager.set_cap_roles required_roles, config_roles

To List Roles:
bundle exec cap <STAGE> deploy:list_roles

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request




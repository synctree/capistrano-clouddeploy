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
Within deploy.rb or whatever multistage cap config file place:

  require 'capistrano-clouddeploy'
  cloud_config_roles = []
  cloud_required_roles = [ :app, :db, :web ]
  stage = <STAGE> 
  configuration = YAML.load(File.open(File.dirname(__FILE__) + "/amazon_ec2.yml"))[stage]
  set :deploy_manager, CapistranoCloudDeploy::AWSManager.new(self, application, stage, configuration)
  deploy_manager.set_cap_roles cloud_required_roles, cloud_config_roles



To List Roles:
  bundle exec cap deploy:list_roles

You'll see output similar to the following:

  * executing `deploy:list_roles'
 ** ROLES:
 ** 
 ** role: web
 ** ec2-23-**-27-232.compute-1.amazonaws.com
 ** 
 ** role: db
 ** ec2-23-**-27-232.compute-1.amazonaws.com
 ** 
 ** role: app
 ** ec2-23-**-27-232.compute-1.amazonaws.com




or if you're using multistage-ext  you can type

  bundle exec cap <STAGE> deploy:list_roles



Tag Machines in Amazon with the following

Name: aws_test_deploy_app/enabled ,  Value: true 
If this is false capistrano will not deploy


Name: aws_test_deploy_app/multistage/environment , Value: <STAGE>
Stage is the stage that this instance applies to


Name: aws_test_deploy_app/capistrano/roles , Value: web,db, app.
aws_test_deploy_app/capistrano/roles  is a comma separated list of roles that the machine has



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request




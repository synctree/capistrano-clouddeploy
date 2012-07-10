# Capistrano::Clouddeploy

Use Capistrano Cloud Deploy Gem to deploy your Amazon EC2 instances.
Tag your instances with the the roles they get then on deployment Capistrano Cloud Deploy can
figure out the roles and load into the capistrano configuration.

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


Cloud deploy will use either the public dns or fall back to
elastic ip address of an ec2 instance


To get last deployed tag:
    bundle exec cap deploy:last_deploy_tag 

You'll see output similar to the following:

     * executing `production_ec2'
     triggering start callbacks for `deploy:last_deploy_tag'
    * executing `multistage:ensure'
    * executing `deploy:last_deploy_tag'
    ** last deploy tag: 1.0


or if you're using multistage-ext  you can type

    bundle exec cap <STAGE> deploy:last_deploy_tag


Tag Machines in Amazon with the following:  (Name and Value)

    <APP_NAME_AS_DEFINED_IN_CAPISTRANO>/enabled (true | false)
    If set to false capistrano will ignore


    <APP_NAME_AS_DEFINED_IN_CAPISTRANO>/multistage/environment (<STAGE_NAME>)
    Stage is the stage that this instance applies to


    <APP_NAME_AS_DEFINED_IN_CAPISTRANO>/capistrano/roles (web,db,app, ROLE, ...)
    <APP_NAME_AS_DEFINED_IN_CAPISTRANO>/capistrano/roles  is a comma separated list of roles that the machine has



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request




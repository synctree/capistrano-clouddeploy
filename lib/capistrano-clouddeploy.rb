require 'capistrano-clouddeploy/aws_manager'

configuration = Capistrano::Configuration.respond_to?(:instance) ?
  Capistrano::Configuration.instance(:must_exist) : Capistrano.configuration(:must_exist)

configuration.load do
  namespace :deploy do

    task :list_roles do

      #TODO: auto discovery of roles
      #
      logger.info "ROLES:"
      roles.keys.each do |role|
        logger.info "\nrole: #{role}"
        find_servers(:roles => role).each do |s|
          logger.info "\t#{s}"
        end 
      end
    end

    task :record_build, :roles => [:manager] do
      if !respond_to?(:bootstrapping) && deploy_manager
        deploy_manager.record_build(branch)
        logger.info("recording #{branch}\n")
      else
        logger.info("bootstrapping so skipping record_build\n")
      end
    end

    task :bootstrap do
      set :bootstrapping, true
      set :bootstrap, true
      stop
      cold
      nginx.restart
      cleanup
    end

  end

  set :bootstrapping, bootstrap if respond_to?(:bootstrap)
  after "deploy:symlink", "deploy:record_build"

  set :branch do
    default_tag = deploy_manager.retrieve_build if deploy_manager
    if respond_to?(:deploy_tag)
      tag = deploy_tag

    elsif respond_to?(:bootstrap) && default_tag
      tag = default_tag

    else
      default_tag ||= `git tag`.split("\n").last

      tag = Capistrano::CLI.ui.ask "Tag to deploy (make sure to push the tag first): [#{default_tag}] "
      tag = default_tag if tag.empty?
    end
    logger.info("branch is #{tag}")
    tag
  end

end


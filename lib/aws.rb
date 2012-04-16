require "capistrano-clouddeploy/version"
require 'AWS'
require 'aws/s3'

module CapistranoCloudDeploy
  class AWS
    def initialize(cap, application, stage, aws_config )
      @application = application
      @stage = stage
      @aws_opts = {
        :access_key_id      => aws_config['access_key_id'],
        :secret_access_key  => aws_config['secret_access_key'],
        :server             => (
          aws_config['server'] || "#{aws_config['region']}.ec2.amazonaws.com"
        )
      }

      @ec2 = AWS::EC2::Base.new(@aws_opts)
      #@as  = AWS::Autoscaling::Base.new(@aws_opts)   #future support for autoscaling
      @cap = cap
    end

    def record_build(branch)
      s3put("#{@application}/#{@stage}/latest-build", branch, 'cag-deploy')
    end

    def retrieve_build
      s3get("#{@application}/#{@stage}/latest-build", 'cag-deploy').value
    end


    def each_role
      roles = {}
  
      @ec2.describe_instances['reservationSet']['item'].each do |reservation_set|
        reservation_set['instancesSet']['item'].each do |instance|
          tags = instance['tagSet'] && instance['tagSet']['item'].kind_of?(Array) ? 
            Hash[instance['tagSet']['item'].collect { |i| [i['key'],i['value'] ]}] : {}

          # if we don't have an application tag then we will pull the application tag
          # information from user-data if there is anything
          if tags["#{@application}/enabled"].nil?
            user_data = @ec2.describe_instance_attribute(
              :instance_id => instance['instanceId'], 
              :attribute => 'userData'
            )['userData']
  
            begin
              if user_data and user_data['value']
                tags.update(YAML.load Base64.decode64(user_data['value']))
              end
            rescue Exception => ex
              STDERR.puts("#{ex}")
            end
          end
  
          next unless tags["#{@application}/enabled"] == "true" &&
                      tags["#{@application}/multistage/environment"] == @stage.to_s
  
          instance_roles = (tags["#{@application}/capistrano/roles"] || "").split(",")
          instance_roles.each do |role_name| roles[role_name] ||= []
            roles[role_name].push(instance)
          end
        end
      end
  
      roles.each_pair do |role_name, instances|
        role_name = role_name.to_sym
        yield(role_name, instances)
      end
  
    end


    def s3put(dest, string_or_stream, bucket, 
                options = { :access => :public_read })
      # Copy this file to S3
  
      AWS::S3::Base.establish_connection!(
       :access_key_id     => @aws_opts[:access_key_id],
       :secret_access_key => @aws_opts[:secret_access_key]
      )
  
      AWS::S3::S3Object.store(dest, string_or_stream, bucket, options)
    end
  
    def s3get(path, bucket)
      AWS::S3::Base.establish_connection!(
       :access_key_id     => @aws_opts[:access_key_id],
       :secret_access_key => @aws_opts[:secret_access_key]
      )
  
      AWS::S3::S3Object.find(path, bucket)
    end


    def set_cap_roles(required_roles, config_roles)
      each_role do |role_name, instances|
        if config_roles.include?(role_name)
          @cap.set role_name, instances.first['privateDnsName'] 
        elsif role_name == :db
          if instances.size == 1
            @cap.role role_name, instances.first['dnsName'], :primary => true
          else
            raise "You have more than one machine set to the db role:\n #{
              instances.delete_if { |i| i['dnsName'].nil? }.
                        collect   { |i| i['dnsName'] }.
                        join(",")
            }\nand we don't know which one is primary"
          end
        else
          @cap.role role_name do
            instances.delete_if { |i| i['dnsName'].nil? }.
                      collect   { |i| i['dnsName'] }
          end
        end
      end
  
      config_roles.each do |role_name|
        @cap.set role_name, nil unless @cap.respond_to?(role_name)
      end
      required_roles.each do |role_name|
        if @cap.role(role_name).size == 0
          @cap.role role_name do [] end
        end
      end
    end

  end
end



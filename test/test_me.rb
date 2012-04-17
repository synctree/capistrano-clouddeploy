require File.dirname(__FILE__) + '/test_helper.rb'

describe 'Cloud Deploy' do

  setup do

    #mock capistrano
    @cap = mock()
    @cap.stubs(:set)
    @cap.stubs(:role)



    #Config File
    @aws_config = YAML.load(File.open(File.dirname(__FILE__) + "/amazon_ec2.yml"))['test']

    @application = "capistrano_test_app"
    @stage = "test"  
    @deploy_manager = CapistranoCloudDeploy::AWSManager.new(@cap, @application, @stage, @aws_config)
  end

  specify "throws error if not in config file" do
    aws_config = YAML.load(File.open(File.dirname(__FILE__) + "/amazon_ec2.yml"))['blank_environment']
    assert_raise do 
      CapistranoCloudDeploy::AWSManager.new(@cap, @application, @stage, aws_config)
    end
  end 


  describe  'configuring environment' do

    setup do
      #mock amazon response
      @amazon_response = { 'reservationSet' => {
                            'item' => [
                              { 'instancesSet' => {
                                  'item' => [ 
                                    { 'tagSet' => {
                                        'item' => [ 
                                          {'key' => "#{@application}/enabled", 'value' => "true"}, 
                                          {'key' => "#{@application}/multistage/environment", 
                                                    'value' => @stage
                                          },
                                          {'key' => "#{@application}/capistrano/roles", 
                                                    'value' => "web"
                                          }
                                        ]
                                      },
                                      "dnsName" => "web.localhost"
                                    },
                                    { 'tagSet' => {
                                        'item' => [ 
                                          {'key' => "#{@application}/enabled", 'value' => "true"}, 
                                          {'key' => "#{@application}/multistage/environment", 
                                                    'value' => @stage
                                          },
                                          {'key' => "#{@application}/capistrano/roles", 
                                                    'value' => "db"
                                          }
                                        ]
                                      },
                                      "dnsName" => "db.localhost"
                                    }

                                  ] 
                                } 
                              } 
                            ]
                          } 
                        }
   

      
    end


    it "should be able to get env info" do
      required_roles = [:web]
      config_roles = [];
      AWS::EC2::Base.any_instance.stubs(:describe_instances).returns(@amazon_response)

      @cap.expects(:role).returns(["", ""])
      @cap.expects(:role).with(:web)
      @cap.expects(:role).with(:db)
      
      @deploy_manager = CapistranoCloudDeploy::AWSManager.new(@cap, @application, @stage, @aws_config)

      @deploy_manager.set_cap_roles required_roles, config_roles
      
 
    end

    #functional test 
    #test it hits amazon and gets the key info
    #mock out ec2 and cap on manager

  end

end


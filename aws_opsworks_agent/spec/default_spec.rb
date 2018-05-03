require "chefspec"

describe "aws_opsworks_agent::default" do
  before do
    allow(Chef::Log).to receive(:warn) # silence fallback warnings
  end

  let(:chef_runner) do
    ChefSpec::SoloRunner.new(platform: "ubuntu", version: "14.04") do |node|
      node.override["aws_opsworks_agent"]["command"] = {
        "command_id" => "some-command-id",
        "instance_id" => "e0973c34-9f8c-42dd-af3f-44dc7cc03803"
      }
      node.override["aws_opsworks_agent"]["resources"]["stack"]["use_custom_cookbooks"] = false
      node.override["aws_opsworks_agent"]["resources"]["users"] = []
      node.override["aws_opsworks_agent"]["resources"]["volumes"] = []
      node.override["aws_opsworks_agent"]["resources"]["instances"] = [
        { # current instance
          "hostname" => "asdf",
          "private_ip" => "172.31.40.184",
          "public_ip" => "52.20.240.149",
          "instance_id" => "e0973c34-9f8c-42dd-af3f-44dc7cc03803",
          "layer_ids" => ["72e98d37-f3bc-40a9-b094-9242575e2efa"],
          "ssh_host_rsa_key_private" => "-----BEGIN RSA PRIVATE KEY-----\r\nrsa private",
          "ssh_host_rsa_key_public" => "rsa public",
          "ssh_host_dsa_key_private" => "-----BEGIN DSA PRIVATE KEY-----\r\ndsa private",
          "ssh_host_dsa_key_public" => "dsa public"
        }
      ]
      node.override["aws_opsworks_agent"]["resources"]["layers"] = [
        {
          "layer_id" => "72e98d37-f3bc-40a9-b094-9242575e2efb",
          "name" => "2015-09-10 13:57:05 +0200 3cd5",
          "shortname" => "custom76e7569c118c",
          "type" => "custom"
        }
      ]
    end
  end

  let(:chef_run) do
    chef_runner.converge(described_recipe)
  end

  shared_examples "a configured system" do
    it "configures system" do
      expect(chef_run).to include_recipe("aws_opsworks_system")
    end
    it "configures ECS stuff" do
      expect(chef_run).to include_recipe("aws_opsworks_ecs")
    end
    it "ensures custom cookbooks are present" do
      expect(chef_run).to include_recipe("aws_opsworks_custom_cookbooks::create_or_delete")
    end
    it "prepares the customers Chef run" do
      expect(chef_run).to include_recipe("aws_opsworks_custom_run")
    end
  end

  context "a setup command" do
    before do
      chef_runner.node.override["aws_opsworks_agent"]["command"]["type"] = "setup"
    end

    it_behaves_like "a configured system"

    it "runs the system setup" do
      expect(chef_run).to include_recipe("aws_opsworks_system::setup")
    end

    it "runs the user setup" do
      expect(chef_run).to include_recipe("aws_opsworks_users")
    end

    it "prepares custom cookbooks" do
      expect(chef_run).to include_recipe("aws_opsworks_custom_cookbooks")
    end

    it "run ebs cookbook if ec2 instance" do
      chef_runner.node.override["ec2"] = {"some" => "data"}
      chef_runner.node.override["aws_opsworks_agent"]["resources"]["instances"][0]["infrastructure_class"] = "ec2"
      expect(chef_run).to include_recipe("aws_opsworks_ebs")
    end

    it "run ebs cookbook if on-premises instance" do
      chef_runner.node.override["aws_opsworks_agent"]["resources"]["instances"][0]["infrastructure_class"] = "on-premises"
      expect(chef_run).to_not include_recipe("aws_opsworks_ebs")
    end
  end

  context "a configure command" do
    before do
      chef_runner.node.override["aws_opsworks_agent"]["command"]["type"] = "configure"
    end

    it_behaves_like "a configured system"

    it "runs the user setup" do
      expect(chef_run).to include_recipe("aws_opsworks_users")
    end

    it "sets the agent version" do
      expect(chef_run).to include_recipe("aws_opsworks_agent_version")
    end
  end

  context "a update_dependencies command" do
    before do
      chef_runner.node.override["aws_opsworks_agent"]["command"]["type"] = "update_dependencies"
    end

    it_behaves_like "a configured system"

    it "runs the OS upgrade" do
      expect(chef_run).to include_recipe("aws_opsworks_system::update_os")
    end
  end

  context "a update_custom_cookbooks command" do
    before do
      chef_runner.node.override["aws_opsworks_agent"]["command"]["type"] = "update_custom_cookbooks"
    end

    it_behaves_like "a configured system"

    it "runs the update cookbooks recipe" do
      expect(chef_run).to include_recipe("aws_opsworks_custom_cookbooks")
    end
  end

  context "a sync_remote_users command" do
    before do
      chef_runner.node.override["aws_opsworks_agent"]["command"]["type"] = "sync_remote_users"
    end

    it_behaves_like "a configured system"

    it "runs the user setup" do
      expect(chef_run).to include_recipe("aws_opsworks_users")
    end
  end

  context "an update_cloud_watch_logs_configuration command" do
    before do
      chef_runner.node.override["aws_opsworks_agent"]["command"]["type"] = "update_cloud_watch_logs_configuration"
    end

    it_behaves_like "a configured system"

    it "runs the cloudwatchlogs cookbook" do
      expect(chef_run).to include_recipe("aws_opsworks_cloudwatchlogs")
    end
  end

  %w{shutdown deploy undeploy start stop restart execute_recipes}.each do |command_type|
    context "a #{command_type} command" do
      before do
        chef_runner.node.override["aws_opsworks_agent"]["command"]["type"] = command_type
      end

      it_behaves_like "a configured system"
    end
  end
end

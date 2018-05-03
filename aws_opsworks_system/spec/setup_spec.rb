require "chefspec"

describe "aws_opsworks_system::setup" do
  before do
    allow(Chef::Log).to receive(:warn) # silence fallback warnings
  end

  let(:chef_run) do
    chef_runner.converge(described_recipe)
  end

  let(:chef_runner) do
    ChefSpec::SoloRunner.new(platform: "amazon", version: "2014.09") do |node|
      node.override["aws_opsworks_agent"] =  {
        "command" => {
          "instance_id" => "e0973c34-9f8c-42dd-af3f-44dc7cc03803"
        },
        "resources" => {
          "instances" => [
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
          ],
          "layers" => [
            {
              "layer_id" => "72e98d37-f3bc-40a9-b094-9242575e2efb",
              "name" => "2015-09-10 13:57:05 +0200 3cd5",
              "shortname" => "custom76e7569c118c",
              "type" => "custom"
            }
          ]
        }
      }
    end
  end

  shared_examples "a configured system" do
    it "configures ldconfig" do
      expect(chef_run).to include_recipe("aws_opsworks_system::ldconfig")
    end

    it "configures yum" do
      expect(chef_run).to include_recipe("aws_opsworks_system::yum")
    end
  end

  context "swap handling" do
    it "not enable swap for instances that have ~2 GB memory" do
      chef_runner.node.automatic["memory"]["total"] = "20000000kb"

      expect(chef_run).to_not include_recipe("aws_opsworks_system::swap")
    end

    it "enable swap for instances that have less than ~2 GB memory" do
      allow_any_instance_of(Chef::Recipe).to receive(:on_premises?).and_return(false)
      chef_runner.node.automatic["memory"]["total"] = "100kb"

      expect(chef_run).to include_recipe("aws_opsworks_system::swap")
    end
  end

  context "EC2 vs on-premises" do
    context "on EC2" do
      before do
        chef_runner.node.automatic["ec2"] = { "some" => "data " }
      end

      it "should include ssh host keys recipe" do
        expect(chef_run).to include_recipe("aws_opsworks_system::ssh_host_keys")
      end

      it_behaves_like "a configured system"
    end

    context "on-premises" do
      it "should include ssh host keys recipe" do
        expect(chef_run).to include_recipe("aws_opsworks_system::ssh_host_keys")
      end

      it_behaves_like "a configured system"
    end
  end

  context "time syncing" do
    context "Ubuntu" do
      before { chef_runner.node.automatic["platform"] = "ubuntu" }

      it "should include the ntp recipe" do
        expect(chef_run).to include_recipe("aws_opsworks_system::ntp")
      end
    end

    context "Amazon Linux" do
      before { chef_runner.node.automatic["platform"] = "amazon" }

      it "should not include the ntp recipe" do
        expect(chef_run).not_to include_recipe("aws_opsworks_system::ntp")
      end
    end

    context "RHEL 7" do
      before do
        chef_runner.node.automatic["platform"] = "redhat"
        chef_runner.node.automatic["platform_family"] = "rhel"
        chef_runner.node.automatic["platform_version"] = "7.1"
      end

      it "should not include the ntp recipe" do
        expect(chef_run).not_to include_recipe("aws_opsworks_system::ntp")
      end
    end
  end
end

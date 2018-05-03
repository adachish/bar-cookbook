require "chefspec"

describe "aws_opsworks_system::chef" do

  let(:aws_opsworks_agent) do
    {
      "command" => {
        "instance_id" => "e0973c34-9f8c-42dd-af3f-44dc7cc03803"
      },
      "resources" => {
        "instances" => [
          {
            "hostname" => "asdf",
            "private_ip" => "172.31.40.184",
            "public_ip" => "52.20.240.149",
            "instance_id" => "e0973c34-9f8c-42dd-af3f-44dc7cc03803"
          }
        ]
      }
    }
  end

  shared_examples "it installs the customer Chef Client" do
    let(:on_disk_file) { File.join(Chef::Config["file_cache_path"], File.basename(url)) }

    it "downloads the Chef Client" do
      expect(chef_run).to create_remote_file(on_disk_file).with(source: url, retries: 6)
    end

    it "installs the Chef Client using retries" do
      expect(chef_run).to upgrade_package("chef-client").with(source: on_disk_file, retries: 2)
    end
  end

  shared_examples "it installs the customer Chef Client for Ubuntu" do
    it_behaves_like "it installs the customer Chef Client"
    it "sets the package provider" do
      expect(chef_run).to upgrade_package("chef-client").with(provider: Chef::Provider::Package::Dpkg)
    end
  end

  let(:chef_run) do
    chef_runner.converge(described_recipe)
  end

  before do
    allow(Chef::Log).to receive(:warn) # silence fallback warnings
  end

  context "Amazon Linux" do
    let(:chef_runner) do
      ChefSpec::SoloRunner.new(platform: "amazon", version: "2014.09") do |node|
        node.override["aws_opsworks_agent"] = aws_opsworks_agent
      end
    end
    let(:url) { "https://opsworks-instance-assets-us-east-1.s3.amazonaws.com/packages/redhat/6/chef-12.18.31-1.el6.x86_64.rpm" }

    it_behaves_like "it installs the customer Chef Client"
  end

  context "RHEL 6" do
    let(:chef_runner) do
      ChefSpec::SoloRunner.new(platform: "redhat", version: "6.5") do |node|
        node.override["aws_opsworks_agent"] = aws_opsworks_agent
      end
    end
    let(:url) { "https://opsworks-instance-assets-us-east-1.s3.amazonaws.com/packages/redhat/6/chef-12.18.31-1.el6.x86_64.rpm" }

    it_behaves_like "it installs the customer Chef Client"
  end

  context "RHEL 7" do
    let(:chef_runner) do
      ChefSpec::SoloRunner.new(platform: "redhat", version: "7.0") do |node|
        node.override["aws_opsworks_agent"] = aws_opsworks_agent
      end
    end
    let(:url) { "https://opsworks-instance-assets-us-east-1.s3.amazonaws.com/packages/redhat/7/chef-12.18.31-1.el7.x86_64.rpm" }

    it_behaves_like "it installs the customer Chef Client"
  end

  context "Ubuntu" do
    let(:url) { "https://opsworks-instance-assets-us-east-1.s3.amazonaws.com/packages/ubuntu/14.04/chef_12.18.31-1_amd64.deb" }

    context "Ubuntu 12.04" do
      let(:chef_runner) do
        ChefSpec::SoloRunner.new(platform: "ubuntu", version: "12.04") do |node|
          node.override["aws_opsworks_agent"] = aws_opsworks_agent
        end
      end
      it_behaves_like "it installs the customer Chef Client for Ubuntu"
    end

    context "Ubuntu 14.04" do
      let(:chef_runner) do
        ChefSpec::SoloRunner.new(platform: "ubuntu", version: "14.04") do |node|
          node.override["aws_opsworks_agent"] = aws_opsworks_agent
        end
      end
      it_behaves_like "it installs the customer Chef Client for Ubuntu"
    end
  end

  context "Debian" do
    let(:chef_runner) do
      ChefSpec::SoloRunner.new(platform: "debian", version: "7.0") do |node|
          node.override["aws_opsworks_agent"] = aws_opsworks_agent
      end
    end
    it "fails the Chef run" do
      expect { chef_run }.to raise_error(RuntimeError)
    end
  end
end

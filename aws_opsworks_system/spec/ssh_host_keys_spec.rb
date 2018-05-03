require "chefspec"

describe "aws_opsworks_system::ssh_host_keys" do
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
            "instance_id" => "e0973c34-9f8c-42dd-af3f-44dc7cc03803",
            "ssh_host_rsa_key_private" => "-----BEGIN RSA PRIVATE KEY-----\r\nrsa private",
            "ssh_host_rsa_key_public" => "rsa public",
            "ssh_host_dsa_key_private" => "-----BEGIN DSA PRIVATE KEY-----\r\ndsa private",
            "ssh_host_dsa_key_public" => "dsa public",
          }
        ]
      }
    }
  end

  let(:chef_runner) do
    ChefSpec::SoloRunner.new do |node|
      node.override["aws_opsworks_agent"] = aws_opsworks_agent
    end
  end

  let(:chef_run) do
    chef_runner.converge(described_recipe)
  end

  context "keys are set" do
    it "renders /etc/ssh/ssh_host_rsa_key" do
      expect(chef_run).to create_file("/etc/ssh/ssh_host_rsa_key").with(
                            :content => "-----BEGIN RSA PRIVATE KEY-----\r\nrsa private"
                          )
    end

    it "renders /etc/ssh/ssh_host_rsa_key.pub" do
      expect(chef_run).to create_file("/etc/ssh/ssh_host_rsa_key.pub").with(
                            :content => "rsa public"
                          )
    end

    it "renders /etc/ssh/ssh_host_dsa_key" do
      expect(chef_run).to create_file("/etc/ssh/ssh_host_dsa_key").with(
                            :content => "-----BEGIN DSA PRIVATE KEY-----\r\ndsa private"
                          )
    end

    it "renders /etc/ssh/ssh_host_dsa_key.pub" do
      expect(chef_run).to create_file("/etc/ssh/ssh_host_dsa_key.pub").with(
                            :content => "dsa public"
                          )
    end
  end
end

require "chefspec"

describe "aws_opsworks_system::motd" do
  let(:aws_opsworks_agent) do
    {
      "command" => {
        "instance_id" => "e0973c34-9f8c-42dd-af3f-44dc7cc03803"
      },
      "resources" => {
        "layers" => [
          {
            "layer_id" => "72e98d37-f3bc-40a9-b094-9242575e2efa",
            "name" => "2015-09-10 13:57:05 +0200 3cd5",
            "shortname" => "custom76e7569c118c",
            "type" => "custom"
          },
          {
            "layer_id" => "72e98d37-f3bc-40a9-b094-9242575e2efb",
            "name" => "2015-09-10 13:57:05 +0200 3cd5",
            "shortname" => "custom76e7569c118c",
            "type" => "custom"
          }
        ],
        "instances" => [
          {
            "ami_id" => "ami-0f4cfd64",
            "architecture" => "x86_64",
            "auto_scaling_type" => nil,
            "availability_zone" => "us-east-1b",
            "created_at" => "2015-09-10T11:57:08+00:00",
            "ebs_optimized" => false,
            "ec2_instance_id" => "i-4818abeb",
            "elastic_ip" => nil,
            "hostname" => "58b480278519fd",
            "instance_id" => "caf8bad6-a103-4591-a857-809fc9e1edcb",
            "instance_type" => "m3.medium",
            "layer_ids" => [
              "72e98d37-f3bc-40a9-b094-9242575e2efa"
            ],
            "os" => "Amazon Linux 2015.03",
            "private_dns" => "ip-172-31-40-184.ec2.internal",
            "private_ip" => "172.31.40.184",
            "public_dns" => "ec2-52-20-240-149.compute-1.amazonaws.com",
            "public_ip" => "52.20.240.149",
            "root_device_type" => "ebs",
            "root_device_volume_id" => "vol-5add44b7",
            "ssh_host_dsa_key_fingerprint" => "2f:94:1d:19:2f:9b:de:44:f7:ba:fc:46:50:e6:dc:41",
            "ssh_host_rsa_key_fingerprint" => "e2:63:e3:7a:52:f5:d9:02:b6:48:53:1d:dd:70:f3:4f",
            "status" => "stopping",
            "subnet_id" => "subnet-3e1a3616",
            "virtualization_type" => "paravirtual"
          },
          {
            "ami_id" => "ami-094cfd62",
            "architecture" => "x86_64",
            "auto_scaling_type" => nil,
            "availability_zone" => "us-east-1b",
            "created_at" => "2015-09-10T12:53:22+00:00",
            "ebs_optimized" => false,
            "ec2_instance_id" => "i-cfa1136c",
            "elastic_ip" => nil,
            "hostname" => "custom76e7569c118c1",
            "instance_id" => "e0973c34-9f8c-42dd-af3f-44dc7cc03803",
            "instance_type" => "c3.large",
            "layer_ids" => [
              "72e98d37-f3bc-40a9-b094-9242575e2efa"
            ],
            "os" => "Amazon Linux 2015.03",
            "private_dns" => "ip-172-31-44-138.ec2.internal",
            "private_ip" => "172.31.44.138",
            "public_dns" => "ec2-52-3-122-127.compute-1.amazonaws.com",
            "public_ip" => "52.3.122.127",
            "root_device_type" => "instance-store",
            "root_device_volume_id" => nil,
            "ssh_host_dsa_key_fingerprint" => "08:1e:55:78:56:06:b1:b5:18:1b:33:8c:d5:cb:ac:66",
            "ssh_host_rsa_key_fingerprint" => "38:43:a9:cf:5a:0f:c6:05:c1:82:a2:d6:e7:23:5b:c8",
            "status" => "requested",
            "subnet_id" => "subnet-3e1a3616",
            "virtualization_type" => "paravirtual"
          }
        ]
      }
    }
  end

  let(:chef_runner) do
    ChefSpec::SoloRunner.new(:platform => "amazon", :version => "2014.09") do |node|
      node.override["aws_opsworks_agent"] = aws_opsworks_agent
    end
  end

  let(:chef_run) do
    chef_runner.converge(described_recipe)
  end

  it "renders template" do
    instance = aws_opsworks_agent["resources"]["instances"].find { |i| i["instance_id"] == aws_opsworks_agent["command"]["instance_id"] }
    expect(chef_run).to create_template("/etc/motd.opsworks-static").with(
      :variables =>
      {
        :stack => aws_opsworks_agent["resources"]["stack"],
        :layers => instance["layer_ids"].map do |layer_ids|
          aws_opsworks_agent["resources"]["layers"].find do |l|
            layer_ids.include?(l["layer_id"])
          end
        end,
        :instance => instance,
        :os_release => "amazon 2014.09"
      }
    )
  end
end

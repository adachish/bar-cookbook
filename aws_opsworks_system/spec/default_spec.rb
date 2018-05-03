require "chefspec"
require_relative "../libraries/helper"

describe "aws_opsworks_system::default" do
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
              "layer_ids" => ["72e98d37-f3bc-40a9-b094-9242575e2efa"]
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
      node.override["ec2"] = {
        "ami_id" => "ami-9a2fb89a"
      }
    end
  end

  it "configures /etc/hosts" do
    expect(chef_run).to include_recipe("aws_opsworks_system::hosts")
  end

  it "configures /etc/motd" do
    expect(chef_run).to include_recipe("aws_opsworks_system::motd")
  end

  it "setup up cleanup" do
    expect(chef_run).to include_recipe("aws_opsworks_system::cleanup")
  end

  it "installs Chef client" do
    expect(chef_run).to include_recipe("aws_opsworks_system::chef")
  end
end

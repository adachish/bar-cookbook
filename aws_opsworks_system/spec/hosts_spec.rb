require "chefspec"

describe "aws_opsworks_system::hosts" do
  let(:aws_opsworks_agent) do
    {
      "command" => {
        "instance_id" => "e0973c34-9f8c-42dd-af3f-44dc7cc03803"
      },
      "resources" => {
        "instances" => [
          { # current instance
            "hostname" => "asdf",
            "private_ip" => "172.31.40.184",
            "public_ip" => "52.20.240.149",
            "instance_id" => "e0973c34-9f8c-42dd-af3f-44dc7cc03803"
          },
          { # no public_ip
            "hostname" => "bsdf",
            "private_ip" => "172.31.40.184",
            "instance_id" => "caf8bad6-a103-4591-a857-809fc9e1edcc"
          },
          { # no private_ip
            "hostname" => "csdf",
            "public_ip" => "52.20.240.149",
            "instance_id" => "caf8bad6-a103-4591-a857-809fc9e1edcd"
          },
          { # no hostname
            "private_ip" => "172.31.40.184",
            "public_ip" => "52.20.240.149",
            "instance_id" => "caf8bad6-a103-4591-a857-809fc9e1edce"
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

  it "renders /etc/hosts" do
    expect(chef_run).to create_template("/etc/hosts").with(
      :variables => {
        :localhost_name => "asdf",
        :nodes => [
          ["172.31.40.184", ["asdf.local", "asdf"]],
          ["52.20.240.149", ["asdf.local-ext", "asdf-ext"]],
          ["172.31.40.184", ["bsdf.local", "bsdf"]],
          ["52.20.240.149", ["csdf.local-ext", "csdf-ext"]]
        ]
      }
    )
  end


  it "renders /etc/hosts when no domain is set" do
    chef_runner.node.automatic["domain"] = nil

    expect(chef_run).to create_template("/etc/hosts").with(
      :variables => {
        :localhost_name => "asdf",
        :nodes => [
          ["172.31.40.184", ["asdf"]],
          ["52.20.240.149", ["asdf-ext"]],
          ["172.31.40.184", ["bsdf"]],
          ["52.20.240.149", ["csdf-ext"]]
        ]
      }
    )
  end
end

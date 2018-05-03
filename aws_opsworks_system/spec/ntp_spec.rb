require "chefspec"

describe "aws_opsworks_system::ntp" do
  let(:chef_runner) { ChefSpec::SoloRunner.new }
  let(:chef_run) { chef_runner.converge(described_recipe) }

  it "installs the ntp package" do
    expect(chef_run).to install_package("ntp").with(:retries => 2)
  end

  it "starts the ntp service" do
    expect(chef_run).to start_service("ntp")
  end

  it "enable the ntp service" do
    expect(chef_run).to enable_service("ntp")
  end
end

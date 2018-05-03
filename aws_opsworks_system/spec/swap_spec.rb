require "chefspec"

describe "aws_opsworks_system::swap" do

  let(:chef_runner) do
    ChefSpec::SoloRunner.new(:platform => "ubuntu", :version => "14.04") do |node|
      node.override["aws_opsworks_system"]["swapfile_name"] = "/var/swapfile"
    end
  end

  let(:chef_run) { chef_runner.converge(described_recipe) }

  it "should create the swap file" do
    expect(chef_run).to run_bash("create swap file /var/swapfile").with(:user => "root", :creates => "/var/swapfile")
  end

  it "have the correct swap parameters" do
    chef_runner.node.automatic["memory"]["total"] = "#{512 * 1024}kB"
    expected = 1488

    expect(chef_run).to run_bash("create swap file /var/swapfile").with(:code => swap_create_script(expected))
  end

  it "should mount the swap file" do
    expect(chef_run).to enable_mount("swap").with(:device => "/var/swapfile", :fstype => "swap")
  end

  it "should activate all swap devices" do
    expect(chef_run).to run_bash("activate all swap devices").with(:user => "root", :code => "swapon -a")
  end

  it "should make the swap file size dependent on the total memory" do
    chef_runner.node.automatic["memory"]["total"] = "#{400 * 1024}kB"
    expected_swap_size = 1600

    expect(chef_run).to run_bash("create swap file /var/swapfile").with(:code => swap_create_script(expected_swap_size))
  end

end

def swap_create_script(size)
  <<-EOC
    dd if=/dev/zero of=/var/swapfile bs=1M count=#{size}
    mkswap /var/swapfile
    chown root:root /var/swapfile
    chmod 0600 /var/swapfile
  EOC
end

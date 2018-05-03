require File.expand_path(File.join(File.dirname(__FILE__), "support", "shared_aws_opsworks_attribs.rb"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "libraries", "search_node.rb"))

describe "search node" do
  include_context "shared_aws_opsworks_attribs"

  let (:instance1) do
    aws_opsworks_attribs["aws_opsworks_agent"]["resources"]["instances"][0]
  end

  let (:instance2) do
    aws_opsworks_attribs["aws_opsworks_agent"]["resources"]["instances"][1]
  end

  let (:resources) do
    aws_opsworks_attribs["aws_opsworks_agent"]["resources"]
  end

  it "sets the role within the run list from the layer short name" do
    search_node1 = AWS::OpsWorks::Agent::SearchNode.new(instance1, resources, nil)
    search_node2 = AWS::OpsWorks::Agent::SearchNode.new(instance2, resources, nil)

    expect(search_node1["run_list"]).to eq(["role[xxx0]", "role[xxx1]"])
    expect(search_node2["run_list"]).to eq(["role[xxx1]"])
  end

  it "sets OHAI-compatible attributes" do
    search_node = AWS::OpsWorks::Agent::SearchNode.new(instance1, resources, nil)

    expect(search_node["default"]["hostname"]).to eq("xxx01")
    expect(search_node["default"]["os"]).to eq("linux")
    expect(search_node["default"]["platform"]).to eq("ubuntu")
    expect(search_node["default"]["platform_family"]).to eq("debian")
    expect(search_node["default"]["ipaddress"]).to eq("10.203.184.14")
    expect(search_node["default"]["fqdn"]).to eq("xxx01")
    expect(search_node["default"]["domain"]).to be nil
    expect(search_node["default"]["network"]["interfaces"]["aws_opsworks_virtual"]["addresses"]["10.203.184.14"]).to eq({"family" => "inet"})
    expect(search_node["default"]["kernel"]["machine"]).to eq("x86_64")
    expect(search_node["default"]["cloud"]["public_ips"]).to eq(["54.144.11.90"])
    expect(search_node["default"]["cloud"]["private_ips"]).to eq(["10.203.184.14"])
    expect(search_node["default"]["cloud"]["public_hostname"]).to eq("ec2-54-144-11-90.compute-1.amazonaws.com")
    expect(search_node["default"]["cloud"]["public_ipv4"]).to eq("54.144.11.90")
    expect(search_node["default"]["cloud"]["local_hostname"]).to eq("ip-10-203-184-14.ec2.internal")
    expect(search_node["default"]["cloud"]["local_ipv4"]).to eq("10.203.184.14")
    expect(search_node["default"]["cloud"]["provider"]).to eq("ec2")
    expect(search_node["default"]["cloud_v2"]["public_ipv4_addrs"]).to eq(["54.144.11.90"])
    expect(search_node["default"]["cloud_v2"]["local_ipv4_addrs"]).to eq(["10.203.184.14"])
    expect(search_node["default"]["cloud_v2"]["public_hostname"]).to eq("ec2-54-144-11-90.compute-1.amazonaws.com")
    expect(search_node["default"]["cloud_v2"]["public_ipv4"]).to eq("54.144.11.90")
    expect(search_node["default"]["cloud_v2"]["local_hostname"]).to eq("ip-10-203-184-14.ec2.internal")
    expect(search_node["default"]["cloud_v2"]["local_ipv4"]).to eq("10.203.184.14")
    expect(search_node["default"]["cloud_v2"]["provider"]).to eq("ec2")
    expect(search_node["default"]["ec2"]["ami_id"]).to eq("ami-acf89cc4")
    expect(search_node["default"]["ec2"]["hostname"]).to eq("ip-10-203-184-14.ec2.internal")
    expect(search_node["default"]["ec2"]["instance_id"]).to eq("i-99999990")
    expect(search_node["default"]["ec2"]["instance_type"]).to eq("c3.large")
    expect(search_node["default"]["ec2"]["local_hostname"]).to eq("ip-10-203-184-14.ec2.internal")
    expect(search_node["default"]["ec2"]["local_ipv4"]).to eq("10.203.184.14")
    expect(search_node["default"]["ec2"]["placement_availability_zone"]).to eq("us-east-1a")
    expect(search_node["default"]["ec2"]["public_hostname"]).to eq("ec2-54-144-11-90.compute-1.amazonaws.com")
    expect(search_node["default"]["ec2"]["public_ipv4"]).to eq("54.144.11.90")
  end

  it "sets domain and FQDN accordingly if doamin is given" do
    search_node = AWS::OpsWorks::Agent::SearchNode.new(instance1, resources, "lovelytest.net")

    expect(search_node["default"]["hostname"]).to eq("xxx01")
    expect(search_node["default"]["fqdn"]).to eq("xxx01.lovelytest.net")
    expect(search_node["default"]["domain"]).to eq("lovelytest.net")
  end

  it "does not set ec2 attributes if EC2 instance ID is not set" do
    instance1["ec2_instance_id"] = nil

    search_node = AWS::OpsWorks::Agent::SearchNode.new(instance1, resources, nil)

    expect(search_node["default"]["hostname"]).to eq("xxx01")
    expect(search_node["default"]["cloud"]["public_ips"]).to eq(["54.144.11.90"])
    expect(search_node["default"]["cloud"]["private_ips"]).to eq(["10.203.184.14"])
    expect(search_node["default"]["cloud"]["public_hostname"]).to eq("ec2-54-144-11-90.compute-1.amazonaws.com")
    expect(search_node["default"]["cloud"]["public_ipv4"]).to eq("54.144.11.90")
    expect(search_node["default"]["cloud"]["local_hostname"]).to eq("ip-10-203-184-14.ec2.internal")
    expect(search_node["default"]["cloud"]["local_ipv4"]).to eq("10.203.184.14")
    expect(search_node["default"]["cloud"]["provider"]).to be nil
    expect(search_node["default"]["cloud_v2"]["public_ipv4_addrs"]).to eq(["54.144.11.90"])
    expect(search_node["default"]["cloud_v2"]["local_ipv4_addrs"]).to eq(["10.203.184.14"])
    expect(search_node["default"]["cloud_v2"]["public_hostname"]).to eq("ec2-54-144-11-90.compute-1.amazonaws.com")
    expect(search_node["default"]["cloud_v2"]["public_ipv4"]).to eq("54.144.11.90")
    expect(search_node["default"]["cloud_v2"]["local_hostname"]).to eq("ip-10-203-184-14.ec2.internal")
    expect(search_node["default"]["cloud_v2"]["local_ipv4"]).to eq("10.203.184.14")
    expect(search_node["default"]["cloud_v2"]["provider"]).to be nil
    expect(search_node["default"]["ec2"]).to be nil
  end

  it "sets the platform- and OS-sepcific attributes for Amazon Linux 2104.03 instances" do
    instance1["os"] = "Amazon Linux"

    search_node = AWS::OpsWorks::Agent::SearchNode.new(instance1, resources, nil)

    expect(search_node["default"]["os"]).to eq("linux")
    expect(search_node["default"]["platform"]).to eq("amazon")
    expect(search_node["default"]["platform_family"]).to eq("rhel")
  end

  it "sets the platform- and OS-sepcific attributes for Amazon Linux 2014.09 instances" do
    instance1["os"] = "Amazon Linux 2014.09"

    search_node = AWS::OpsWorks::Agent::SearchNode.new(instance1, resources, nil)

    expect(search_node["default"]["os"]).to eq("linux")
    expect(search_node["default"]["platform"]).to eq("amazon")
    expect(search_node["default"]["platform_family"]).to eq("rhel")
  end

  it "sets the platform- and OS-sepcific attributes for Ubuntu 12.04 LTS instances" do
    instance1["os"] = "Ubuntu 12.04 LTS"

    search_node = AWS::OpsWorks::Agent::SearchNode.new(instance1, resources, nil)

    expect(search_node["default"]["os"]).to eq("linux")
    expect(search_node["default"]["platform"]).to eq("ubuntu")
    expect(search_node["default"]["platform_family"]).to eq("debian")
  end

  it "sets the platform- and OS-sepcific attributes for Ubuntu 14.04 LTS instances" do
    instance1["os"] = "Ubuntu 14.04 LTS"

    search_node = AWS::OpsWorks::Agent::SearchNode.new(instance1, resources, nil)

    expect(search_node["default"]["os"]).to eq("linux")
    expect(search_node["default"]["platform"]).to eq("ubuntu")
    expect(search_node["default"]["platform_family"]).to eq("debian")
  end

end

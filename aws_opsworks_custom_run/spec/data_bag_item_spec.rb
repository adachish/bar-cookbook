require File.expand_path(File.join(File.dirname(__FILE__), "support", "shared_aws_opsworks_attribs.rb"))

require File.expand_path(File.join(File.dirname(__FILE__), "..", "libraries", "data_bag_item.rb"))

describe "data bag item" do
  include_context "shared_aws_opsworks_attribs"

  context "aws_opsworks_app" do
    it "sets the shortname and the deploy flag for an app resource if its ID is part of the command's app IDs" do
      data_bag_item_first_app = AWS::OpsWorks::Agent::AppDataBagItem.new(
        aws_opsworks_attribs["aws_opsworks_agent"]["resources"]["apps"].first,
        aws_opsworks_attribs["aws_opsworks_agent"]
      )

      expect(data_bag_item_first_app["shortname"]).to eq("node")
      expect(data_bag_item_first_app["deploy"]).to be true
    end

    it "sets the shortname, but not the deploy flag for an app resource if its ID is not part of the command's app IDs" do
      aws_opsworks_attribs["aws_opsworks_agent"]["command"]["args"]["app_ids"] = ["55555555-1111-3333-7777-99999999"]

      data_bag_item_first_app = AWS::OpsWorks::Agent::AppDataBagItem.new(
        aws_opsworks_attribs["aws_opsworks_agent"]["resources"]["apps"].first,
        aws_opsworks_attribs["aws_opsworks_agent"]
      )

      expect(data_bag_item_first_app["shortname"]).to eq("node")
      expect(data_bag_item_first_app["deploy"]).to be_falsey
    end
  end

  context "aws_opsworks_layer" do
    it "sets the hostname and the role attribute for an instance resource belonging to two layers" do
      data_bag_item_first_app = AWS::OpsWorks::Agent::InstanceDataBagItem.new(
        aws_opsworks_attribs["aws_opsworks_agent"]["resources"]["instances"].first,
        aws_opsworks_attribs["aws_opsworks_agent"]
      )

      expect(data_bag_item_first_app["hostname"]).to eq("xxx01")
      expect(data_bag_item_first_app["role"]).to eq(["xxx0", "xxx1"])
    end

    it "sets the hostname and the role attribute for an instance resource belonging to one layer" do
      data_bag_item_first_app = AWS::OpsWorks::Agent::InstanceDataBagItem.new(
        aws_opsworks_attribs["aws_opsworks_agent"]["resources"]["instances"][1],
        aws_opsworks_attribs["aws_opsworks_agent"]
      )

      expect(data_bag_item_first_app["hostname"]).to eq("xxx11")
      expect(data_bag_item_first_app["role"]).to eq(["xxx1"])
    end

    it "sets the shortname for a layer resource" do
      data_bag_item_first_app = AWS::OpsWorks::Agent::LayerDataBagItem.new(
        aws_opsworks_attribs["aws_opsworks_agent"]["resources"]["layers"].first,
        aws_opsworks_attribs["aws_opsworks_agent"]
      )

      expect(data_bag_item_first_app["shortname"]).to eq("xxx0")
    end
  end

  context "aws_opsworks_instance" do
    it "flags the instance as 'self' if it is the current instance" do
      data_bag_item_first_instance = AWS::OpsWorks::Agent::InstanceDataBagItem.new(
        aws_opsworks_attribs["aws_opsworks_agent"]["resources"]["instances"][0],
        aws_opsworks_attribs["aws_opsworks_agent"]
      )

      expect(data_bag_item_first_instance["self"]).to eq(true)
    end

    it "should not flag other instances as 'self'" do
      data_bag_item_first_instance = AWS::OpsWorks::Agent::InstanceDataBagItem.new(
        aws_opsworks_attribs["aws_opsworks_agent"]["resources"]["instances"][1],
        aws_opsworks_attribs["aws_opsworks_agent"]
      )

      expect(data_bag_item_first_instance["self"]).to eq(false)
    end

  end

  context "aws_opsworks_command" do
    it "sets type and Id on the command" do
      data_bag_item_command = AWS::OpsWorks::Agent::CommandDataBagItem.new(
        aws_opsworks_attribs["aws_opsworks_agent"]["resources"]["command"],
        aws_opsworks_attribs["aws_opsworks_agent"]
      )

      expect(data_bag_item_command["command_id"]).to eq("5d287f2b-9d88-49d1-b2c2-77ec6c675c2b")
      expect(data_bag_item_command["type"]).to eq("setup")
      expect(data_bag_item_command["sent_at"]).to eq("2015-01-02T12:00:00+00:00")
    end
  end

  context "aws_opsworks_stack" do
    it "sets the stack ID for a stack resource" do
      data_bag_item_first_app = AWS::OpsWorks::Agent::StackDataBagItem.new(
        aws_opsworks_attribs["aws_opsworks_agent"]["resources"]["stack"],
        aws_opsworks_attribs["aws_opsworks_agent"]
      )

      expect(data_bag_item_first_app["stack_id"]).to eq("ef1033ed-55e9-4e4d-aacb-4512eff34f6d")
    end
  end

  context "aws_opsworks_user" do
    it "sets the username for a user resource" do
      data_bag_item_first_user = AWS::OpsWorks::Agent::UserDataBagItem.new(
        aws_opsworks_attribs["aws_opsworks_agent"]["resources"]["users"].first,
        aws_opsworks_attribs["aws_opsworks_agent"]
      )

      expect(data_bag_item_first_user["username"]).to eq("iam99")
    end
  end

  context "aws_opsworks_elastic_load_balancer" do
    it "sets the elastic_load_balancer_name for a ELB resource" do
      data_bag_item_first_elb = AWS::OpsWorks::Agent::ElasticLoadBalancerDataBagItem.new(
        aws_opsworks_attribs["aws_opsworks_agent"]["resources"]["elastic_load_balancers"].first,
        aws_opsworks_attribs["aws_opsworks_agent"]
      )

      expect(data_bag_item_first_elb["elastic_load_balancer_name"]).to eq("beta-classic")
    end
  end

  context "aws_opsworks_rds_db_instance" do
    it "sets the rds_db_instance_arn for a RDS DB" do
      data_bag_item_first_rds_db = AWS::OpsWorks::Agent::RdsDbInstanceDataBagItem.new(
        aws_opsworks_attribs["aws_opsworks_agent"]["resources"]["rds_db_instances"].first,
        aws_opsworks_attribs["aws_opsworks_agent"]
      )

      expect(data_bag_item_first_rds_db["rds_db_instance_arn"]).to eq("arn:aws:rds:us-east-1:916730580261:db:beta")
    end
  end

  context "aws_opsworks_ecs_cluster" do
    it "sets the ecs_cluster_arn for a ecs cluster" do
      data_bag_item_first_ecs_cluster = AWS::OpsWorks::Agent::EcsClusterDataBagItem.new(
        aws_opsworks_attribs["aws_opsworks_agent"]["resources"]["ecs_clusters"].first,
        aws_opsworks_attribs["aws_opsworks_agent"]
      )

      expect(data_bag_item_first_ecs_cluster["ecs_cluster_arn"]).to eq("arn:aws:ecs:us-east-1:916730580261:cluster/mycluster")
    end
  end
end

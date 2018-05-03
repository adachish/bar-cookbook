shared_context "shared_aws_opsworks_attribs" do

  let (:aws_opsworks_attribs) do
    {
      "aws_opsworks_agent" => {
        "command" => {
          "type" => "setup",
          "args" => {
            "app_ids" => [
              "e8374b3c-ba2c-4d66-a441-62c33ffa31bc"
            ]
          },
          "sent_at" => "2015-01-02T12:00:00+00:00",
          "command_id" => "5d287f2b-9d88-49d1-b2c2-77ec6c675c2b",
          "iam_user_arn" => nil,
          "instance_id" => "8cf4254d-f381-41cc-b69c-e20fbacf07d1"
        },
        "resources" => {
          "command" => {
            "type" => "setup",
            "args" => {
              "app_ids" => [
                "e8374b3c-ba2c-4d66-a441-62c33ffa31bc"
              ]
            },
            "sent_at" => "2015-01-02T12:00:00+00:00",
            "command_id" => "5d287f2b-9d88-49d1-b2c2-77ec6c675c2b",
            "iam_user_arn" => nil,
            "instance_id" => "8cf4254d-f381-41cc-b69c-e20fbacf07d1"
          },
          "apps" => [
            {
              "app_id" => "e8374b3c-ba2c-4d66-a441-62c33ffa31bc",
              "stack_id" => "ef1033ed-55e9-4e4d-aacb-4512eff34f6d",
              "shortname" => "node",
              "name" => "node",
              "description" => nil,
              "data_sources" => [
                {
                  "type" => "None"
                }
              ],
              "type" => "nodejs",
              "app_source" => {
                "password" => "xxx",
                "revision" => "xxx",
                "ssh_key" => "xxx",
                "type" => "git",
                "url" => "https://github.com/xxx/very-simple-node-app.git",
                "user" => "xxx"
              },
              "domains" => [
                "xxx.net",
                "node"
              ],
              "enable_ssl" => true,
              "ssl_configuration" => {
                "certificate" => "xxx",
                "private_key" => "xxx",
                "chain" => nil
              },
              "attributes" => {
                "auto_bundle_on_deploy" => true,
                "aws_flow_ruby_settings" => {
                },
                "document_root" => nil,
                "rails_env" => nil
              },
              "environment" => {
                "xxx" => "xxx"
              }
            }
          ],
          "layers" => [
            {
              "stack_id" => "ef1033ed-55e9-4e4d-aacb-4512eff34f6d",
              "layer_id" => "cf3e819a-ed99-4511-aa0c-5b6597a6b067",
              "type" => "custom",
              "name" => "xxx 0",
              "shortname" => "xxx0",
              "custom_instance_profile_arn" => nil,
              "custom_security_group_ids" => [],
              "default_security_group_names" => [
                "AWS-OpsWorks-Custom-Server"
              ],
              "packages" => [],
              "volume_configurations" => [],
              "enable_auto_healing" => true,
              "auto_assign_elastic_ips" => false,
              "auto_assign_public_ips" => true,
              "default_recipes" => {
                "setup" => [],
                "configure" => [],
                "deploy" => [],
                "undeploy" => [],
                "shutdown" => []
              },
              "custom_recipes" => {
                "setup" => [
                  "custom_xxx0",
                  "custom_xxx1::do_it",
                  "custom_xxx2"
                ],
                "configure" => [],
                "deploy" => [],
                "undeploy" => [],
                "shutdown" => []
              },
              "created_at" => "2014-12-24T12:00:00+00:00",
              "install_updates_on_boot" => nil,
              "use_ebs_optimized_instances" => false
            },
            {
              "stack_id" => "ef1033ed-55e9-4e4d-aacb-4512eff34f6d",
              "layer_id" => "1ce1c2bf-f2eb-4cd6-9d41-13354fc12f55",
              "type" => "custom",
              "name" => "xxx 1",
              "shortname" => "xxx1",
              "custom_instance_profile_arn" => nil,
              "custom_security_group_ids" => [],
              "default_security_group_names" => [
                "AWS-OpsWorks-Custom-Server"
              ],
              "packages" => [],
              "volume_configurations" => [],
              "enable_auto_healing" => true,
              "auto_assign_elastic_ips" => false,
              "auto_assign_public_ips" => true,
              "default_recipes" => {
                "setup" => [],
                "configure" => [],
                "deploy" => [],
                "undeploy" => [],
                "shutdown" => []
              },
              "custom_recipes" => {
                "setup" => [],
                "configure" => [],
                "deploy" => [],
                "undeploy" => [],
                "shutdown" => []
              },
              "created_at" => "2014-12-25T12:00:00+00:00",
              "install_updates_on_boot" => nil,
              "use_ebs_optimized_instances" => false
            }
          ],
          "instances" => [
            {
              "ami_id" => "ami-acf89cc4",
              "architecture" => "x86_64",
              "auto_scaling_type" => nil,
              "availability_zone" => "us-east-1a",
              "created_at" => "2015-01-01T12:00:00+00:00",
              "ebs_optimized" => false,
              "ec2_instance_id" => "i-99999990",
              "elastic_ip" => nil,
              "hostname" => "xxx01",
              "install_updates_on_boot" => true,
              "instance_id" => "8cf4254d-f381-41cc-b69c-e20fbacf07d1",
              "instance_profile_arn" => "arn:aws:iam::999999999999:instance-profile/aws-opsworks-ec2-role",
              "instance_type" => "c3.large",
              "last_service_error_id" => nil,
              "layer_ids" => [
                "cf3e819a-ed99-4511-aa0c-5b6597a6b067",
                "1ce1c2bf-f2eb-4cd6-9d41-13354fc12f55"
              ],
              "os" => "Ubuntu 14.04 LTS",
              "private_dns" => "ip-10-203-184-14.ec2.internal",
              "private_ip" => "10.203.184.14",
              "public_dns" => "ec2-54-144-11-90.compute-1.amazonaws.com",
              "public_ip" => "54.144.11.90",
              "root_device_type" => "ebs",
              "root_device_volume_id" => "vol-99999990",
              "security_group_ids" => [
                "sg-f1ccdf99",
                "sg-f5ccdf9d"
              ],
              "ssh_host_dsa_key_fingerprint" => "xxx",
              "ssh_host_rsa_key_fingerprint" => "xxx",
              "ssh_key_name" => "id_rsa",
              "stack_id" => "ef1033ed-55e9-4e4d-aacb-4512eff34f6d",
              "status" => "online",
              "subnet_id" => nil,
              "virtualization_type" => "hvm"
            },
            {
              "ami_id" => "ami-acf89cc4",
              "architecture" => "x86_64",
              "auto_scaling_type" => nil,
              "availability_zone" => "us-east-1a",
              "created_at" => "2015-01-01T12:00:00+00:00",
              "ebs_optimized" => false,
              "ec2_instance_id" => "i-99999991",
              "elastic_ip" => nil,
              "hostname" => "xxx11",
              "install_updates_on_boot" => true,
              "instance_id" => "8cf4254d-f381-41cc-b69c-e20fbacf07d2",
              "instance_profile_arn" => "arn:aws:iam::999999999999:instance-profile/aws-opsworks-ec2-role",
              "instance_type" => "c3.large",
              "last_service_error_id" => nil,
              "layer_ids" => [
                "1ce1c2bf-f2eb-4cd6-9d41-13354fc12f55"
              ],
              "os" => "Ubuntu 14.04 LTS",
              "private_dns" => "ip-10-203-184-14.ec2.internal",
              "private_ip" => "10.203.184.14",
              "public_dns" => "ec2-54-144-11-90.compute-1.amazonaws.com",
              "public_ip" => "54.144.11.90",
              "root_device_type" => "ebs",
              "root_device_volume_id" => "vol-99999991",
              "security_group_ids" => [
                "sg-f1ccdf99",
                "sg-f5ccdf9d"
              ],
              "ssh_host_dsa_key_fingerprint" => "xxx",
              "ssh_host_rsa_key_fingerprint" => "xxx",
              "ssh_key_name" => "id_rsa",
              "stack_id" => "ef1033ed-55e9-4e4d-aacb-4512eff34f6d",
              "status" => "online",
              "subnet_id" => nil,
              "virtualization_type" => "hvm"
            },
          ],
          "users" => [
            {
              "iam_user_arn" => "arn:aws:iam::999999999999:user/iam99",
              "remote_access" => true,
              "administrator_privileges" => false,
              "ssh_public_key" => "xxx",
              "username" => "iam99",
              "unix_user_id" => 2099
            }
          ],
          "stack" => {
            "stack_id" => "ef1033ed-55e9-4e4d-aacb-4512eff34f6d",
            "name" => "xxx",
            "arn" => "arn:aws:opsworks:us-east-1:999999999999:stack/ef1033ed-55e9-4e4d-aacb-4512eff34f6d/",
            "region" => "us-east-1",
            "vpc_id" => nil,
            "attributes" => {
              "color" => "rgb(45, 114, 184)"
            },
            "service_role_arn" => "arn:aws:iam::999999999999:role/aws-opsworks-service-role-beta",
            "default_instance_profile_arn" => "arn:aws:iam::999999999999:instance-profile/aws-opsworks-ec2-role",
            "default_os" => "Ubuntu 14.04 LTS",
            "hostname_theme" => "Layer_Dependent",
            "default_availability_zone" => "us-east-1a",
            "default_subnet_id" => nil,
            "configuration_manager" => {
              "name" => "Chef",
              "version" => "11.14"
            },
            "use_custom_cookbooks" => true,
            "use_opsworks_security_groups" => true,
            "custom_cookbooks_source" => {
              "type" => "s3",
              "url" => "https://s3.amazonaws.com/opsworks-example-cookbooks/multiple_windows_custom_cookbooks.zip",
              "username" => nil,
              "password" => nil,
              "ssh_key" => nil,
              "revision" => nil
            },
            "default_ssh_key_name" => "id_rsa",
            "created_at" => "2014-12-24T12:00:00+00:00",
            "default_root_device_type" => "ebs"
          },
          "elastic_load_balancers" => [
             {
               "elastic_load_balancer_name" => "beta-classic",
               "dns_name" => "beta-classic-676964272.us-east-1.elb.amazonaws.com",
               "layer_id" => "2243ee46-dbf3-4346-9f5c-e021655a9a4b"
             }
          ],
          "rds_db_instances" => [
            {
              "rds_db_instance_arn" => "arn:aws:rds:us-east-1:916730580261:db:beta",
              "db_instance_identifier" => "beta",
              "db_user" => "beta",
              "db_password" => "password",
              "region" => "us-east-1",
              "address" => "beta.caz4ehv5ntxm.us-east-1.rds.amazonaws.com",
              "engine" => "mysql",
              "missing_on_rds" => false
            }
          ],
          "ecs_clusters" => [
            {
              "ecs_cluster_arn" => "arn:aws:ecs:us-east-1:916730580261:cluster/mycluster",
              "ecs_cluster_name" => "mycluster"
            }
          ]
        }
      }
    }
  end

end

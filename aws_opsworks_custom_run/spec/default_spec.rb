require "chefspec"

describe "aws_opsworks_custom_run::default" do

  let(:chef_runner) do
    ChefSpec::SoloRunner.new(step_into: ["aws_opsworks_custom_run"]) do |node|
      node.override["aws_opsworks_agent"]["command"]["command_id"] = "0123-4567-abcddcba"
      node.override["aws_opsworks_agent"]["chef"]["customer_json"] = Base64.encode64(JSON.dump({}))
      node.override["aws_opsworks_agent"]["chef"]["customer_data_bags"] = Base64.encode64(JSON.dump({}))
      node.override["aws_opsworks_custom_run"]["base_dir"] = "/chef_dir"
      node.override["aws_opsworks_custom_run"]["cookbook_path"] = [ "/chef_cookbooks" ]
    end
  end

  let(:chef_run) do
    chef_runner.converge(described_recipe)
  end

  context "aws_opsworks_agent->command" do
    it "prepares customer Chef run with aws_opsworks_agent->command->command_id" do
      expect(chef_run).to prepare_opsworks_custom_run("0123-4567-abcddcba")
    end
  end

  context "client run environment" do

    it "creates run dir and required subdirs and renders client.rb in run dir" do
      expect(chef_run).to prepare_opsworks_custom_run("0123-4567-abcddcba")
      expect(chef_run).to create_directory(::File.join("/chef_dir", "runs", "0123-4567-abcddcba"))
      expect(chef_run).to create_directory(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "data_bags"))
      expect(chef_run).to create_directory(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "nodes"))
      expect(chef_run).to render_file(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "client.rb")).with_content(
        /cookbook_path\s+\[\s*['"]\/chef_cookbooks['"]\s*\].*data_bag_path\s+['"]\/chef_dir\/runs\/0123-4567-abcddcba\/data_bags['"]\s*\n\s*node_path\s+['"]\/chef_dir\/runs\/0123-4567-abcddcba\/nodes['"].*/m
      )
    end

    it "does not filter on execute_recipes without blacklisted commands and renders attribs.json in run dir" do
      chef_runner.node.override["aws_opsworks_agent"]["command"]["type"] = "execute_recipes"
      chef_runner.node.override["aws_opsworks_agent"]["chef"]["customer_recipes"] = ["something", "another_thing::perform"]

      expect(chef_run).to prepare_opsworks_custom_run("0123-4567-abcddcba")
      expect(chef_run).to create_directory(::File.join("/chef_dir", "runs", "0123-4567-abcddcba"))
      expect(chef_run).to render_file(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "attribs.json")).with_content(
        /"run_list"\s*:\s*\[\s*"recipe\[something\]"\s*,\s*"recipe\[another_thing::perform\]"\s*\]/
      )
    end

    it "filters out execute_recipes[aws_opsworks_agent_version] and renders attribs.json in run dir" do
      chef_runner.node.override["aws_opsworks_agent"]["command"]["type"] = "execute_recipes"
      chef_runner.node.override["aws_opsworks_agent"]["chef"]["customer_recipes"] = ["aws_opsworks_agent_version", "something"]

      expect(chef_run).to prepare_opsworks_custom_run("0123-4567-abcddcba")
      expect(chef_run).to create_directory(::File.join("/chef_dir", "runs", "0123-4567-abcddcba"))
      expect(chef_run).to render_file(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "attribs.json")).with_content(/"run_list"\s*:\s*\[\s*"recipe\[something\]"\s*\]/)
    end

    it "filters out 'opsworks' top level node in Custom JSON" do
      custom_json = {
        "opsworks" => {
          "aws_opsworks_agent_version" => 1
        },
        "mykey" => "myvalue"
      }
      chef_runner.node.override["aws_opsworks_agent"]["chef"]["customer_json"] = Base64.encode64(JSON.dump(custom_json))

      allow(Chef::Log).to receive(:warn) # silence log warning

      expect(chef_run).to     prepare_opsworks_custom_run("0123-4567-abcddcba")
      expect(chef_run).to     render_file(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "attribs.json")).with_content(/mykey/)
      expect(chef_run).to     render_file(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "attribs.json")).with_content(/myvalue/)
      expect(chef_run).to_not render_file(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "attribs.json")).with_content(/opsworks/)
      expect(chef_run).to_not render_file(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "attribs.json")).with_content(/agent version/)
    end
  end

  context "search" do
    before do
      chef_runner.node.override["aws_opsworks_agent"]["command"]["type"] = "execute_recipes"
      chef_runner.node.override["aws_opsworks_agent"]["command"]["args"]["app_ids"] = ["aaaaaaaa-bbbb-cccc-dddd-eeeeeeee"]
      chef_runner.node.override["aws_opsworks_agent"]["chef"]["customer_recipes"] = ["something"]
      chef_runner.node.override["aws_opsworks_agent"]["resources"]["apps"] = [
        {
          "app_id" => "aaaaaaaa-bbbb-cccc-dddd-eeeeeeee",
          "shortname" => "some_app"
        }
      ]
      chef_runner.node.override["aws_opsworks_agent"]["resources"]["instances"] = [
        {
          "instance_id" => "01234567-89ab-cdef-0123-456789ab",
          "hostname" => "instance-one",
          "layer_ids" => [
            "aaaaaaaa-bbbb-cccc-dddd-eeeeeeee"
          ],
          "status" => "online"
        },
        {
          "instance_id" => "456789ab-89ab-cdef-0123-01234567",
          "hostname" => "instance-two",
          "layer_ids" => [
            "00000000-1111-2222-3333-44444444"
          ],
          "status" => "requested"
        },
        {
          "instance_id" => "fedcba98-7654-3210-0123-456789ab",
          "hostname" => "instance-three",
          "layer_ids" => [
            "00000000-1111-2222-3333-44444444",
            "aaaaaaaa-bbbb-cccc-dddd-eeeeeeee"
          ],
          "status" => "online"
        }
      ]
      chef_runner.node.override["aws_opsworks_agent"]["resources"]["layers"] = [
        {
          "layer_id" => "aaaaaaaa-bbbb-cccc-dddd-eeeeeeee",
          "shortname" => "some_layer"
        },
        {
          "layer_id" => "00000000-1111-2222-3333-44444444",
          "shortname" => "some_other_layer"
        }
      ]
      chef_runner.node.override["aws_opsworks_agent"]["resources"]["stack"]["stack_id"] = "ffffffff-0000-eeee-1111-dddddddd"
      chef_runner.node.override["aws_opsworks_agent"]["resources"]["command"] = {
        "args" => { "app_ids" => [] },
        "command_id" => "0123-4567-abcddcba",
        "iam_user_arn" => "arn:aws:iam::123456789012:user/some-user",
        "instance_id" => "01234567-89ab-cdef-0123-456789ab",
        "sent_at" => "2016-03-23T04:22:48+00:00",
        "type" => "execute_recipes"
      }
      chef_runner.node.override["aws_opsworks_agent"]["resources"]["users"] = [
        {
          "iam_user_arn" => "arn:aws:iam::916730580261:user/userA",
          "username" => "userA"
        },
        {
          "iam_user_arn" => "arn:aws:iam::916730580261:user/userB",
          "username" => "userB"
        }
      ]
      chef_runner.node.override["aws_opsworks_agent"]["resources"]["elastic_load_balancers"] = [
        { "elastic_load_balancer_name" => "elb-a" }
      ]
      chef_runner.node.override["aws_opsworks_agent"]["resources"]["rds_db_instances"] = [
        { "rds_db_instance_arn" => "arn:aws:rds:us-east-1:916730580261:db:heinz" }
      ]
      chef_runner.node.override["aws_opsworks_agent"]["resources"]["ecs_clusters"] = [
        { "ecs_cluster_arn" => "arn:aws:ecs:us-east-1:916730580261:cluster/mycluster" }
      ]
    end

    context "#nodes" do
      it "writes two node files for search if two online instance resources given and domain not set" do
        chef_runner.node.automatic["domain"] = nil

        expect(chef_run).to prepare_opsworks_custom_run("0123-4567-abcddcba")

        expect(chef_run).to create_directory(::File.join("/chef_dir", "runs", "0123-4567-abcddcba"))

        expect(chef_run).to create_directory(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "nodes"))
        expect(chef_run).to render_file(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "nodes", "instance-one.json")).with_content(
          /"aws_opsworks_instance_id": "01234567-89ab-cdef-0123-456789ab"/
        )
        expect(chef_run).to_not render_file(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "nodes", "instance-two.json"))
        expect(chef_run).to render_file(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "nodes", "instance-three.json")).with_content(
          /"aws_opsworks_instance_id": "fedcba98-7654-3210-0123-456789ab"/
        )
      end

      it "writes two FQDN node files for search if two online instance resources given and domain set" do
        chef_runner.node.automatic["domain"] = "fancyad.mycorp.net"

        expect(chef_run).to prepare_opsworks_custom_run("0123-4567-abcddcba")

        expect(chef_run).to create_directory(::File.join("/chef_dir", "runs", "0123-4567-abcddcba"))

        expect(chef_run).to create_directory(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "nodes"))
        expect(chef_run).to render_file(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "nodes", "instance-one.fancyad.mycorp.net.json")).with_content(
          /"aws_opsworks_instance_id": "01234567-89ab-cdef-0123-456789ab"/
        )
        expect(chef_run).to_not render_file(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "nodes", "instance-one.json"))
        expect(chef_run).to_not render_file(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "nodes", "instance-two.json"))
        expect(chef_run).to_not render_file(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "nodes", "instance-two.fancyad.mycorp.net.json"))
        expect(chef_run).to_not render_file(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "nodes", "instance-three.json"))
        expect(chef_run).to render_file(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "nodes", "instance-three.fancyad.mycorp.net.json")).with_content(
          /"aws_opsworks_instance_id": "fedcba98-7654-3210-0123-456789ab"/
        )
      end
    end

    context "#databags" do
      it "creates databag directories" do
        expect(chef_run).to create_directory(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "data_bags"))
      end

      context "customer databags" do
        it "write customers databag with multiple items" do
          chef_runner.node.override["aws_opsworks_agent"]["chef"]["customer_data_bags"] = Base64.encode64(
            JSON.dump({
                        "my_first_bag" => { "item1" => { "a" => "b", "value" => "something"},
                                           "item2" => { "c" => "d", "value" => "otherthing"} },
                       "my_second_bag" => {}
                      }))

          expect(chef_run).to create_directory(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "data_bags", "my_first_bag"))
          expect(chef_run).to render_file(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "data_bags", "my_first_bag", "item1.json")).with_content(/"value": "something"/)
          expect(chef_run).to render_file(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "data_bags", "my_first_bag", "item2.json")).with_content(/"value": "otherthing"/)
        end

        it "creates empty databag indices" do
          chef_runner.node.override["aws_opsworks_agent"]["chef"]["customer_data_bags"] = Base64.encode64(
            JSON.dump({
                        "my_first_bag" => {},
                        "my_second_bag" => {}
                      }))

          expect(chef_run).to create_directory(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "data_bags", "my_first_bag"))
          expect(chef_run).to create_directory(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "data_bags", "my_second_bag"))
        end

        context "with strange data bag values" do
          it "is resilient to databag items will null value" do
            chef_runner.node.override["aws_opsworks_agent"]["chef"]["customer_data_bags"] = Base64.encode64(
              JSON.dump({
                          "my_first_bag" => nil,
                          "my_second_bag" => {}
                        }))

            expect { chef_run }.to raise_error(ArgumentError, /expected data bag items to be a hash/i)
          end

          it "is resilient to databag items with string value" do
            chef_runner.node.override["aws_opsworks_agent"]["chef"]["customer_data_bags"] = Base64.encode64(
              JSON.dump({
                          "my_first_bag" => { "item1" => "stringy" },
                          "my_second_bag" => {}
                        }))

            expect {chef_run }.to raise_error(ArgumentError, /error writing.*item1.*my_first_bag/i)
          end
        end
      end

      context "opsworks databags" do
        it "writes aws_opsworks_app databags" do
          expect(chef_run).to create_directory(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "data_bags", "aws_opsworks_app"))
          expect(chef_run).to render_file(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "data_bags", "aws_opsworks_app", "some_app.json")).with_content(/"deploy": true/)
        end

        it "writes aws_opsworks_instance databags" do
          expect(chef_run).to create_directory(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "data_bags", "aws_opsworks_instance"))
          expect(chef_run).to render_file(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "data_bags", "aws_opsworks_instance", "instance-one.json"  )).with_content(/"role": \[\n\s*"some_layer"\n\s*\]/)
          expect(chef_run).to render_file(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "data_bags", "aws_opsworks_instance", "instance-two.json"  )).with_content(/"role": \[\n\s*"some_other_layer"\n\s*\]/)
          expect(chef_run).to render_file(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "data_bags", "aws_opsworks_instance", "instance-three.json")).with_content(/"role": \[\n\s*"some_other_layer",\n\s*"some_layer"\n\s*\]/)
        end

        it "writes aws_opsworks_layer databags" do
          expect(chef_run).to create_directory(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "data_bags", "aws_opsworks_layer"))
          expect(chef_run).to render_file(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "data_bags", "aws_opsworks_layer", "some_layer.json"))
          expect(chef_run).to render_file(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "data_bags", "aws_opsworks_layer", "some_other_layer.json"))
        end

        it "writes aws_opsworks_stack databags" do
          expect(chef_run).to create_directory(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "data_bags", "aws_opsworks_stack"))
          expect(chef_run).to render_file(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "data_bags", "aws_opsworks_stack", "ffffffff-0000-eeee-1111-dddddddd.json"))
        end

        it "writes aws_opsworks_command databags" do
          expect(chef_run).to create_directory(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "data_bags", "aws_opsworks_command"))
          expect(chef_run).to render_file(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "data_bags", "aws_opsworks_command", "0123-4567-abcddcba.json")).with_content(%r(arn:aws:iam::123456789012:user/some-user))
        end

        it "writes aws_opsworks_user databags" do
          expect(chef_run).to create_directory(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "data_bags", "aws_opsworks_user"))
          expect(chef_run).to render_file(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "data_bags", "aws_opsworks_user", "userA.json")).with_content(/arn:aws:iam::916730580261:user.userA/)
          expect(chef_run).to render_file(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "data_bags", "aws_opsworks_user", "userB.json")).with_content(/arn:aws:iam::916730580261:user.userB/)
        end

        it "writes aws_opsworks_elastic_load_balancer databags" do
          expect(chef_run).to create_directory(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "data_bags", "aws_opsworks_elastic_load_balancer"))
          expect(chef_run).to render_file(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "data_bags", "aws_opsworks_elastic_load_balancer", "elb-a.json")).with_content(/elastic_load_balancer_name/)
        end

        it "writes aws_opsworks_rds_db_instance databags" do
          expect(chef_run).to create_directory(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "data_bags", "aws_opsworks_rds_db_instance"))
          expect(chef_run).to render_file(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "data_bags", "aws_opsworks_rds_db_instance", "arn_aws_rds_us-east-1_916730580261_db_heinz.json")).with_content(/heinz/)
        end

        it "writes aws_opsworks_ecs_cluster databags" do
          expect(chef_run).to create_directory(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "data_bags", "aws_opsworks_ecs_cluster"))
          expect(chef_run).to render_file(::File.join("/chef_dir", "runs", "0123-4567-abcddcba", "data_bags", "aws_opsworks_ecs_cluster", "arn_aws_ecs_us-east-1_916730580261_cluster_mycluster.json")).with_content(/mycluster/)
        end
      end
    end
  end
end

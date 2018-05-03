require File.expand_path(File.join(File.dirname(__FILE__), "..", "libraries", "aws_opsworks_custom_run_helper.rb"))

describe "AWS::OpsWorks::CustomRun" do
  describe "#filter_run_list" do
    it "filters blacklisted entries" do
      filtered = AWS::OpsWorks::CustomRun.filter_run_list_entries("execute_recipes", ["my_recipe", "aws_opsworks_agent_version"])
      expect(filtered).to match_array(["my_recipe"])
    end

    it "returns list entries for known commands" do
      filtered = AWS::OpsWorks::CustomRun.filter_run_list_entries("execute_recipes", ["my_recipe", "my_other_recipe"])
      expect(filtered).to match_array(["my_other_recipe", "my_recipe"])
    end

    it "returns list entries for unknown commands" do
      filtered = AWS::OpsWorks::CustomRun.filter_run_list_entries("some command", ["my_recipe"])
      expect(filtered).to match_array(["my_recipe"])
    end

    it "returns a empty array for a nil runlist" do
      expect(AWS::OpsWorks::CustomRun.filter_run_list_entries("some", nil)).to match_array([])
    end
  end
end

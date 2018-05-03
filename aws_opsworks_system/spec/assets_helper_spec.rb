require_relative "../libraries/assets_helper"

describe AWS::OpsWorks::System::Assets do
  context "#asset_bucket" do
    before do
      allow(IO).to receive(:read).and_call_original
      allow(IO).to receive(:read).with("/etc/aws/opsworks/instance-agent.yml").and_return <<EOS
---
:assets_download_bucket: opsworks-instance-assets-eu-east-23.s3.amazonaws.com
EOS
    end

    it "extracts the assets_download_bucket" do
      expect(AWS::OpsWorks::System::Assets.asset_bucket).to eq("opsworks-instance-assets-eu-east-23.s3.amazonaws.com")
    end

    it "has a fallback on error" do
      expect(YAML).to receive(:load).and_raise("Error")
      expect(Chef::Log).to receive(:warn).with(/unable to read/i)
      expect(AWS::OpsWorks::System::Assets.asset_bucket).to eq("opsworks-instance-assets-us-east-1.s3.amazonaws.com")
    end
  end

  context "#url_for" do
    it "builds the correct url" do
      expect(AWS::OpsWorks::System::Assets).to receive(:asset_bucket).and_return "bucket"
      expect(AWS::OpsWorks::System::Assets.url_for("mykey")).to eq("https://bucket/packages/mykey")
    end
  end
end

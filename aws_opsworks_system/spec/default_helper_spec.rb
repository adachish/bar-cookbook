require_relative "../libraries/helper"

describe AWS::OpsWorks::System::Helper do
  context "swap" do

    let(:swapper) { AWS::OpsWorks::System::Helper }

    it "should return true when swap is needed" do
      expect(swapper.swap_needed?("1019452kB")).to eq(true)
    end

    it "should return false when exceeding min memory" do
      expect(swapper.swap_needed?("2500000kB")).to eq(false)
    end

    it "should specify the minimum amount of memory" do
      expect(AWS::OpsWorks::System::Helper::MIN_MEMORY).to eq(2000)
    end

  end
end

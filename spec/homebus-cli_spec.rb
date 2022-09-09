require 'spec_helper'

require 'homebus-cli/version'
require 'homebus-cli/cli'

require 'homebus/config'

describe HomebusCLI do
  context "Version number" do
    it "Has a version number" do
      expect(HomebusCLI::VERSION).not_to be_nil
      expect(HomebusCLI::VERSION.class).to be String
    end
  end 
end

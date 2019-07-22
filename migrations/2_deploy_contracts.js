var CrowdFundingCampaign = artifacts.require("./CrowdFundingCampaign.sol");
var CrowdFundingCampaignFactory = artifacts.require("./CrowdFundingCampaignFactory.sol");

module.exports = function(deployer) {
  deployer.deploy(CrowdFundingCampaign, "title", "description", 100, 1000);
  deployer.deploy(CrowdFundingCampaignFactory);
};

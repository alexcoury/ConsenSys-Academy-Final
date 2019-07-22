pragma solidity ^0.5.0;

import "./CrowdFundingCampaign.sol";
import "./SafeMath.sol";

contract CrowdFundingCampaignFactory {
    using SafeMath for uint256;

    CrowdfundingCampaign[] public deployedCampaigns;

    //Function that allows creator to create a new crowdFunding campaign
    function createCampaign(uint256 minimum, string memory title, string memory description, uint256 goal) public {
        CrowdfundingCampaign newCampaign = new CrowdfundingCampaign(title, description, minimum, goal);
        deployedCampaigns.push(newCampaign);
    }

    //returns the details of a campaign
    function getDeployedCampaigns() public view returns (CrowdfundingCampaign[] memory) {
        return deployedCampaigns;
    }
}
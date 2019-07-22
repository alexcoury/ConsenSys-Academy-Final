pragma solidity ^0.5.0;

//Importing OpenZeppelin's SafeMath Implementation
import "./SafeMath.sol";

contract CrowdfundingCampaign {
    using SafeMath for uint256;

    address payable public creator;
    mapping(address => bool) contributors; //bool to check if contributor supported a campaign
    string public title;
    string public description;
    uint256 public minimumContribution; //minimum constribution a contributor can send set by the creator
    uint256 public targetGoal; //The target goal of the campaign set by the creator
    uint256 public contributorsCount; //count of contributors for a single campaign

    struct Withdrawal {
        string description; //reason for withdraw of campaign
        uint value; //value creator wants to withdrawl
        address payable recipient; //creator can send to either themself or support someone else
        bool complete;
        uint approvalCount; //contributors vote on if the withdrawl should happen
        mapping(address => bool) approvals;
    }

    Withdrawal[] public withdrawals;

    constructor(string memory _title, string memory _description, uint256 _minimum, uint256 _goal) public {
        creator = msg.sender;
        title = _title;
        description = _description;
        minimumContribution = _minimum;
        targetGoal = _goal;
    }

    //modifier to check if the caller is the owner of the campaign
    modifier isCreator {
        require(msg.sender == creator, "You must be the owner");
        _;
    }

    //modifier to check if the caller is a contributor of the campaign
    modifier isContributor {
        require(contributors[msg.sender], "You must be a contributor");
        _;
    }

    /** @dev Function to fund the campaign as a contributor
       */
    function contribute() public payable isContributor {
        require(msg.value >= minimumContribution, "The contribution must be above the minimum Contribution");
        contributors[msg.sender] = true;
        contributorsCount++;
    }

    /** @dev Creator creates a withdrawl request to withdrawl funds from raised crowdfund
     */
    function createWithdrawlRequest(string memory withdrawalDescription, uint value, address payable recipient) public isCreator {
        Withdrawal memory newWithdrawal = Withdrawal ({
            description: withdrawalDescription,
            value: value,
            recipient: recipient,
            complete: false,
            approvalCount: 0
        });
        withdrawals.push(newWithdrawal);
    }

    /** @dev Returns the details for a withdrawl request
     */
    function readWithdrawlRequest(uint index)public view returns
    (string memory withdrawalDescription, uint256 value,
    address recipient, bool complete, uint256 approvalCount) {
        withdrawalDescription = withdrawals[index].description;
        value = withdrawals[index].value;
        recipient = withdrawals[index].recipient;
        complete = withdrawals[index].complete;
        approvalCount = withdrawals[index].approvalCount;
    }

    /** @dev Contributor(s) vote on withdrawl request created by the creator of the crowdfund
     */
    function approveWithdrawal(uint index) public isContributor {
        Withdrawal storage withdrawal = withdrawals[index];

        require(!withdrawal.approvals[msg.sender], "Contributor has already voted");

        withdrawal.approvals[msg.sender] = true;

        withdrawal.approvalCount++;
    }

    /** @dev Function for Creator to withdrawl funds if contributor vote is grater than 50%
     */
    function finalizeWithdrawal(uint index) public isCreator {
        Withdrawal storage withdrawal = withdrawals[index];

        require(withdrawal.approvalCount > (contributorsCount / 2),"Approval must be greater than 50%");
        require(!withdrawal.complete, "Withdrawl must not already be complete");

        withdrawal.recipient.transfer(withdrawal.value);
        withdrawal.complete = true;
    }


}
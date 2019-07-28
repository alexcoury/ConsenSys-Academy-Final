var CrowdFundingCampaign = artifacts.require('CrowdFundingCampaign')
let catchRevert = require("./exceptionsHelpers.js").catchRevert
const BN = web3.utils.BN

contract('CrowdfundingCampaign', function(accounts){

    const firstAccount = accounts[0]
    const secondAccount = accounts[1]
    const thirdAccount = accounts[3]

    const title = "title"
    const description = "description"
    const minimumContribution = 100
    const targetGoal = 1000
    const contributorsCount = 0
    const value = 100

    let instance 

    beforeEach(async () =>  {
        instance = await CrowdFundingCampaign.new(title, description, minimumContribution, targetGoal)
    })

    describe("Setup", async() => {

        it("Owner/Creator should be set to the deploying address", async() => {
            const owner = await instance.creator()
            assert.equal(owner, firstAccount, "the deploying address should be the owner")
        })
    })

    describe("Functions", () => {

        it("readCampaign() should return a CrowdFunding Campaign details", async() => {
            const project = await instance.readCampaign()

            assert.equal(project._title, title, "this project titles should match")
            assert.equal(project._description, description, "this project descriptions should match")
            assert.equal(project._minimum, minimumContribution, "The project minimum contribution should match")
            assert.equal(project._goal, targetGoal, "The target goals of the project should match")
            assert.equal(project._count, contributorsCount, "The countributors counts should match")
        })

        describe("contribute()", async () => {
            it("Contribution should only be able to be made if msg.value is greater than or equal to minimum", async () => {
                await catchRevert(instance.contribute({from: secondAccount}))
            })

            it("The Contribution count should increment appropriately when contribution are made", async() => {
                await instance.contribute({from: secondAccount})
                const projectDetails = await instance.readCampaign()
                const count = projectDetails._count 
                
                assert.equal(count, 1, "The campaign should have one contributor recorded")
            })
        })

        describe("createWithdrawlRequest() & ReadWithdrawalRequest()", async() => {
            it("createWithdrawlRequest should create a new Withdrawal Request and read it", async() => {
                await instance.createWithdrawlRequest(description, targetGoal, firstAccount)
                const withdrawalDetails = await instance.readWithdrawlRequest(0)

                assert.equal(withdrawalDetails.withdrawalDescription, description, "the withdrawal descriptions should match") 
                assert.equal(withdrawalDetails.value, targetGoal, "the withdrawal values should match")
                assert.equal(withdrawalDetails.recipient, firstAccount, "The withdrawal recipients should match")
                assert.equal(withdrawalDetails.complete, false, "The withdrawal status should be false")
                assert.equal(withdrawalDetails.approvalCount, 0, "The intial approval account should be 0")
            })
        })
        
        describe("approveWithdrawal()", async () => {
            it("Approve request should submit a contributor vote to increment the count", async() => {
                await instance.createWithdrawlRequest(description, targetGoal, firstAccount)
                await instance.contribute({from: secondAccount}) //fix
                await instance.approveWithdrawal(0, {from: secondAccount}) //fix
                const withdrawalDetails = await instance.readWithdrawlRequest(0)

                assert.equal(withdrawalDetails.approvalCount, 1, "The approval count should increment")
            })
        })
    })
})
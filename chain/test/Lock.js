const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Crowdfunding contract", function () {
  let Crowdfunding;
  let crowdfunding;
  let ERC20Token;
  let erc20Token;
  let owner;
  let donor;

  before(async () => {
    [owner, donor] = await ethers.getSigners();

    const ERC20TokenFactory = await ethers.getContractFactory("ERC_Remote");
    erc20Token = await ERC20TokenFactory.deploy();
    await erc20Token.waitForDeployment();

    Crowdfunding = await ethers.getContractFactory("Crowdfunding");
    crowdfunding = await Crowdfunding.deploy(erc20Token.target);

    await crowdfunding.waitForDeployment();
  });

  it("should create a campaign with a non-zero goal", async () => {
    await crowdfunding.connect(owner).creator(100);
    const campaign = await crowdfunding.Authors(1);
    expect(campaign.goal).to.equal(100);
  });

  it("should donate to a campaign", async function () {
    await erc20Token.mint(donor.address, 1000);

    await erc20Token.connect(donor).approve(crowdfunding.target, 1000);

    await crowdfunding.connect(donor).donate(1, 50);

    const donatedAmount = await crowdfunding.donatedAmount(1, donor.address);

    expect(donatedAmount).to.equal(50);
  });

  it("should un-donate from a campaign", async function () {
    await crowdfunding.connect(donor).unDonate(1, 20);
    const donatedAmount = await crowdfunding.donatedAmount(1, donor.address);

    expect(donatedAmount).to.equal(30);
  });
});

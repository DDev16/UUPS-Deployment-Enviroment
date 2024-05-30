const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("Deployment and Interaction Simulation", function () {
  let deployer, initialOwner;
  let psychoGems, psychoChibis, stakingContract;

  before(async function () {
    [deployer, initialOwner] = await ethers.getSigners();
    console.log("Deploying All Contracts with account:", deployer.address);

    // Deploying PsychoGems (ERC20)
    const ERC20 = await ethers.getContractFactory("PsychoGems");
    psychoGems = await upgrades.deployProxy(ERC20, [initialOwner.address], { initializer: 'initialize', kind: 'uups' });
    console.log("Psycho Gems deployed to:", psychoGems.address);

    // Deploying PsychoChibis (ERC721)
    const ERC721 = await ethers.getContractFactory("PsychoChibis");
    psychoChibis = await upgrades.deployProxy(ERC721, [initialOwner.address, psychoGems.address], { initializer: 'initialize', kind: 'uups' });
    console.log("Psycho Chibis deployed to:", psychoChibis.address);

    // Deploy the StakingContract as a UUPS upgradeable contract
    const StakingContract = await ethers.getContractFactory("ChaoticCreationsStaking");
    stakingContract = await upgrades.deployProxy(StakingContract, [psychoGems.address, psychoChibis.address, initialOwner.address], { initializer: 'initialize', kind: 'uups' });
  });

  it("Should have deployed all contracts correctly", async function () {
    expect(psychoGems.address).to.be.properAddress;
    expect(psychoChibis.address).to.be.properAddress;
    expect(stakingContract.address).to.be.properAddress;

    console.log("Psycho Gems deployed to:", psychoGems.address);
    console.log("Psycho Chibis deployed to:", psychoChibis.address);
    console.log("StakingContract deployed to:", stakingContract.address);
  });

  // Add more tests here to interact with your deployed contracts
});

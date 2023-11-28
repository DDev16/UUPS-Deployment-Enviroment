import { expect, use } from 'chai';
import { Contract } from 'ethers';
import { deployContract, MockProvider, solidity } from 'ethereum-waffle';

use(solidity);

describe('StakingContract', function () {
  let stakingContract;
  let customTokenMock;
  let owner;
  let user;

  before(async () => {
    [owner, user] = new MockProvider().getWallets();

    // Deploy the StakingContract and initialize it
    const StakingContract = await ethers.getContractFactory('StakingContract');
    stakingContract = await deployContract(owner, StakingContract, [owner.address]);

    // Create a mock contract for the custom token
    customTokenMock = await deployContract(owner, CustomToken, [1000]); // Adjust this to match your custom token initialization.

    // Add the custom token mock as a supported contract
    await stakingContract.addSupportedContract(customTokenMock.address);
  });

  it('should allow a user to stake tokens', async () => {
    // User stakes a token by interacting with the mock contract
    await customTokenMock.mock.ownerOf.withArgs(1).returns(user.address); // Set an expectation for ownerOf
    await expect(stakingContract.stake(customTokenMock.address, 1))
      .to.emit(stakingContract, 'Staked')
      .withArgs(0, user.address, customTokenMock.address, 1);
  });

  it('should calculate rewards correctly', async () => {
    // Calculate the expected reward for the user's stake
    const expectedReward = 10; // Assuming the user's tokenId is in the first tier

    // Claim the reward
    await expect(stakingContract.claimReward(0))
      .to.emit(stakingContract, 'RewardClaimed')
      .withArgs(user.address, expectedReward);

    // Verify the user's total rewards and staking points
    const stakeInfo = await stakingContract.stakes(0);
    expect(stakeInfo.totalRewards).to.equal(expectedReward);
    expect(stakeInfo.stakingPoints).to.equal(0); // First tier staking points
  });

  it('should allow a user to spend staking points', async () => {
    // Spend staking points
    const amountToSpend = 5;
    await expect(stakingContract.spendStakingPoints(0, amountToSpend))
      .to.emit(stakingContract, 'StakingPointsSpent')
      .withArgs(user.address, amountToSpend);

    // Verify the user's remaining staking points
    const stakeInfo = await stakingContract.stakes(0);
    expect(stakeInfo.stakingPoints).to.equal(0);
  });

  it('should allow a user to unstake tokens', async () => {
    // Unstake the tokens
    await expect(stakingContract.unstake(0))
      .to.emit(stakingContract, 'Unstaked')
      .withArgs(0, user.address, customTokenMock.address, 1);

    // Verify that the user's stake no longer exists
    const stakeInfo = await stakingContract.stakes(0);
    expect(stakeInfo.staker).to.equal(ethers.constants.AddressZero);
  });
});

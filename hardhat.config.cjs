require('@nomicfoundation/hardhat-ethers');
require('@openzeppelin/hardhat-upgrades');

// Load environment variables if using dotenv
require('dotenv').config();

module.exports = {
  solidity: {
    version: "0.8.22",
    settings: {
      optimizer: {
        enabled: true,
        runs: 800,
      },
    },
  },
  paths: {
    sources: "./contracts",
  },
  networks: {
    localhost: {
      chainId: 31337,
      accounts: [
        process.env.REACT_APP_SECRET_KEY, // Account 0 private key
        // Add more accounts if needed
      ],
    },
   
    songbird: {
      gas: "auto",
      gasPrice: "auto",
      gasMultiplier: 1,
      url: "https://songbird-api.flare.network/ext/bc/C/rpc",
      accounts: [process.env.REACT_APP_SECRET_KEY],
      chainId: 19
    },
  
    goerli: {
      gas: "auto",
      gasPrice: "auto",
      gasMultiplier: 1,
      url: "https://ethereum-goerli.publicnode.com",
      chainId: 5,
      accounts: [
        process.env.REACT_APP_SECRET_KEY, // Account 0 private key
      ],
    },
  
  },
};

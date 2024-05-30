require('@nomicfoundation/hardhat-ethers');
require('@openzeppelin/hardhat-upgrades');


// Load environment variables if using dotenv
require('dotenv').config();

module.exports = {
  solidity: {
    version: "0.8.20",
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

  sourcify: {
    enabled: true // Enable Sourcify verification
  },


  etherscan: {
    apiKey: {
      flare: "dummy-key",
      songbird: "dummy-key",
      coston: "dummy-key",
    },
    customChains: [
      {
        network: "flare",
        chainId: 14,
        urls: {
          apiURL: "https://flare-explorer.flare.network/api",
          browserURL: "https://flare-explorer.flare.network"
        }
      },
      {
        network: "songbird",
        chainId: 19,
        urls: {
          apiURL: "https://songbird-explorer.flare.network/api",
          browserURL: "https://songbird-explorer.flare.network"
        }
      },
      {
        network: "coston",
        chainId: 16,
        urls: {
          apiURL: "https://coston-explorer.flare.network/api",
          browserURL: "https://coston-explorer.flare.network"
        }
        
      }
    ]
  },
  networks: {
    localhost: {
      chainId: 31337,
      accounts: [
        process.env.REACT_APP_SECRET_KEY, // Account 0 private key
        // Add more accounts if needed
      ],
    },

    flare: {
      gas: "auto",
      gasPrice: "auto",
      gasMultiplier: 1,
      url: "https://rpc.ankr.com/flare",
      accounts: [process.env.REACT_APP_SECRET_KEY],
      chainId: 14
    },
   
    songbird: {
      gas: "auto",
      gasPrice: "auto",
      gasMultiplier: 1,
      url: "https://songbird-api.flare.network/ext/bc/C/rpc",
      accounts: [process.env.REACT_APP_SECRET_KEY],
      chainId: 19
    },

    coston: {
      gas: "auto",
      gasPrice: "auto",
      gasMultiplier: 1,
      url: "https://coston-api.flare.network/ext/C/rpc",
      accounts: [process.env.REACT_APP_SECRET_KEY],
      chainId: 16
    },

    mumbai: {
      gas: "auto",
      gasPrice: "auto",
      gasMultiplier: 1,
      url: "https://polygon-mumbai-bor-rpc.publicnode.com",
      chainId: 80001,
      accounts: [
        process.env.REACT_APP_SECRET_KEY, // Account 0 private key
      ],
    },

    localhost: {
      url: "http://127.0.0.1:8545/",
      chainId: 31337,
      accounts: [
        process.env.REACT_APP_SECRET_KEY, // Account 0 private key
      ],
    },

    polygon: {
      gas: "auto",
      gasPrice: "auto",
      gasMultiplier: 1,
      url: "https://polygon-rpc.com",
      chainId: 137,
      accounts: [
        process.env.REACT_APP_SECRET_KEY, // Account 0 private key
      ],
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

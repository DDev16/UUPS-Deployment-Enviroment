require('@openzeppelin/hardhat-upgrades');

module.exports = {
  solidity: {
    version: "0.8.22",

    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  paths: {
    sources: "./contracts",
  },
  networks: {
    localhost: {
      chainId: 31337, // Set the chain ID to 31337 for your local network.
     },
     songbird: {
      gas: "auto",
      gasPrice: "auto",
      gasMultiplier: 1,

      url: "https://sgb.ftso.com.au/ext/bc/C/rpc",
      chainId: 19,

      accounts: ['0xd96076ee4237473680fc4b18da1d19508fc02ff7cf1c4c06ff0b5ace32144552'],
    },
    goerli: {
      gas: "auto",
      gasPrice: "auto",
      gasMultiplier: 1,

      url: "https://ethereum-goerli.publicnode.com",
      chainId: 5,

      accounts: ['0xd96076ee4237473680fc4b18da1d19508fc02ff7cf1c4c06ff0b5ace32144552'],
    },
  },
};

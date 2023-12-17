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
      chainId: 31337,
      accounts: ['0xea6c44ac03bff858b476bba40716402b03e41b8e97e276d1baec7c37d42484a0'], // Your private key here

     },
     songbird: {
      gas: "auto",
      gasPrice: "auto",
      gasMultiplier: 1,

      url: "https://sgb.ftso.com.au/ext/bc/C/rpc",
      chainId: 19,

    },
    goerli: {
      gas: "auto",
      gasPrice: "auto",
      gasMultiplier: 1,

      url: "https://ethereum-goerli.publicnode.com",
      chainId: 5,

    },
  },
};

require("@nomiclabs/hardhat-waffle");

module.exports = {
  networks: {
    hardhat: {
      chainId: 1337
    },
    mumbai: {
      url: `https://polygon-mumbai.infura.io/v3/${process.env.projectId}`,
      accounts: []
    },
    mainnet: {
      url: `https://polygon-mainnet.infura.io/v3/${process.env.projectId}`,
      accounts: []
    },
    
  },
  solidity: "0.8.4",
};


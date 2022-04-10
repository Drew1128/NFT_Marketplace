require("@nomiclabs/hardhat-waffle");
const fs = require("fs");
const privateKey = fs.readFileSync(".secret").toString();

module.exports = {
 defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      chainId: 1337
    },
     mumbai: {
      url: `https://polygon-mumbai.infura.io/v3/ac8b909387d344b0850e066a2b944424`,
      accounts: [privateKey]
    },
   /* mainnet: {
      url: `https://polygon-mainnet.infura.io/v3/${process.env.projectId}`,
      accounts: [privateKey]
    },
    */
  },
  solidity: "0.8.4",
};


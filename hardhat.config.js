require('dotenv').config();

require('@nomiclabs/hardhat-etherscan');
require('@nomiclabs/hardhat-waffle');
require('hardhat-gas-reporter');
require('solidity-coverage');
require('hardhat-contract-sizer');

module.exports = {
  solidity: {
    version: '0.8.10',
    settings: {
      optimizer: {
        enabled: false,
        runs: 999999,
      },
    },
  },
  networks: {
    polygon: {
      url: process.env.POLYGON_ENDPOINT_URL,
      accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    mumbai: {
      url: process.env.MUMBAI_ENDPOINT_URL,
      accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
  },
  gasReporter: {
    enabled: false,
    currency: 'USD',
  },
  etherscan: {
    apiKey: process.env.POLYGONSCAN_API_KEY,
  },
};

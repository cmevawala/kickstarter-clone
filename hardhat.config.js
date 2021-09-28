require("@nomiclabs/hardhat-waffle");
// require("hardhat-gas-reporter");

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.7",
  gasReporter: {
    currency: 'ETH',
    gasPrice: 21,
    enabled: true
  }
};

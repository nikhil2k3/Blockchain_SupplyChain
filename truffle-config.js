module.exports = {
  networks: {
    development: {
      host: "127.0.0.1", // Localhost
      port: 7545,        // Ganache port
      network_id: "5777",   // Match any network id
    },
  },

  compilers: {
    solc: {
      version: "0.8.20", // Use the same version as your smart contracts
    },
  },

  // Optional: Set default mocha configuration
  mocha: {
    timeout: 100000,
  },
};

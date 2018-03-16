require('babel-polyfill')
require('babel-register')({
  // Ignore everything in node_modules except node_modules/zeppelin-solidity.
  presets: ['es2015'],
  plugins: ['syntax-async-functions', 'transform-regenerator'],
  ignore: /node_modules\/(?!zeppelin-solidity)/
})

module.exports = {
  networks: {
    testrpc: {
      // gas: 4.5 * 1e6,
      gasPrice: 1,
      network_id: '*',
      host: 'localhost',
      port: 8545,
      from: '0x90f8bf6a479f320ead074411a4b0e7944ea8c9c1'     // Use the address we derived
    },
    coverage: {
      host: 'localhost',
      network_id: '*',
      port: 8555,         // <-- If you change this, also set the port option in .solcover.js.
      gas: 0xfffffffffff, // <-- Use this high gas value
      gasPrice: 0x01      // <-- Use this low gas price
    }
  },
  solc: {
    optimizer: {
      enabled: true,
      runs: 200
    }
  }
}

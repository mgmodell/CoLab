// The source code including full typescript support is available at: 
// https://github.com/shakacode/react_on_rails_demo_ssr_hmr/blob/master/config/webpack/test.js

const { generateWebpackConfig } = require("shakapacker");

const webpackConfig = generateWebpackConfig;

const testOnly = (_clientWebpackConfig, _serverWebpackConfig) => {
  // place any code here that is for test only
  devServer: {
    host: '0.0.0.0',
    port: 3010
    allowedHosts: 'all',
    watchOptions: {
      poll: 1000,
    },
    hot: true,
  }
}

module.exports = webpackConfig(testOnly)

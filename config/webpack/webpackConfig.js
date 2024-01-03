// The source code including full typescript support is available at: 
// https://github.com/shakacode/react_on_rails_demo_ssr_hmr/blob/master/config/webpack/webpackConfig.js

const { generateWebpackConfig, inliningCss } = require('shakapacker');
const ReactRefreshWebpackPlugin = require('@pmmmwh/react-refresh-webpack-plugin');
const isDevelopment = process.env.NODE_ENV !== 'production';

const webpackConfig = generateWebpackConfig();

if (isDevelopment && inliningCss) {
  webpackConfig.plugins.push(
    new ReactRefreshWebpackPlugin({
      overlay: {
        sockPort: webpackConfig.devServer.port,
      },
    })
  );
}

module.exports = webpackConfig;

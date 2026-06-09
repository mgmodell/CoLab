// The source code including full typescript support is available at: 
// https://github.com/shakacode/react_on_rails_demo_ssr_hmr/blob/master/config/webpack/development.js

const { devServer, inliningCss } = require('shakapacker');

const webpackConfig = require('./webpackConfig');

const developmentEnvOnly = (clientWebpackConfig, _serverWebpackConfig) => {
  // plugins
  if (inliningCss) {
    // Note, when this is run, we're building the server and client bundles in separate processes.
    // Thus, this plugin is not applied to the server bundle.

    // eslint-disable-next-line global-require
    const ReactRefreshPlugin = require('@rspack/plugin-react-refresh');
    clientWebpackConfig.plugins.push(
      new ReactRefreshPlugin({
        overlay: {
          sockIntegration: 'wds'
        },
      }),
    );
  }
};

module.exports = webpackConfig(developmentEnvOnly);

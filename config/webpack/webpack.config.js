const { webpackConfig, merge } = require('shakapacker');
const ReactRefreshWebpackPlugin = require('@pmmmwh/react-refresh-webpack-plugin');
//const ForkTSCheckerWebpackPlugin = require("fork-ts-checker-webpack-plugin");

// See the shakacode/shakapacker README and docs directory for advice on customizing your webpackConfig.
const options = {
  module: {
    rules: [
      {
        test: /\.tsx?$/,
        exclude: /node_modules/,
        loader: 'babel-loader',
      },
    ],
  },
  plugins: [
    new ReactRefreshWebpackPlugin(),
  ],
  resolve: {
    fallback: { url: require.resolve('url') },
    extensions:
    ['.tsx','.ts','.js','.svg','.png','.jpg','.jpeg','.gif']
  }
}

module.exports = merge(webpackConfig, {
  //plugins: [new ForkTSCheckerWebpackPlugin()],
}, options);

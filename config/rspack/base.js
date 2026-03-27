const { generateWebpackConfig, merge } = require('shakapacker');
//const { webpackConfig, merge } = require('@rails/webpacker');
const webpackConfig = generateWebpackConfig()

module.exports = merge(webpackConfig, customConfig);


process.env.NODE_ENV = process.env.NODE_ENV || 'staging'

const webpackConfig = require('./webpackConfig')

const stagingEnvOnly = (_clientWebpackConfig, _serverWebpackConfig) => {
  // place any code here that is for staging only
}

module.exports = webpackConfig(stagingEnvOnly)

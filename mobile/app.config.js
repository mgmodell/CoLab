// Lets the container tooling point the app at a different backend at build time
module.exports = ({ config }) => ({
  ...config,
  extra: {
    ...config.extra,
    apiUrl: process.env.COLAB_API_URL || config.extra.apiUrl
  }
});

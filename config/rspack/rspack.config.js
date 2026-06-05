const path = require("node:path");
const { NormalModuleReplacementPlugin } = require("@rspack/core");
const { generateRspackConfig } = require("shakapacker/rspack");

const config = generateRspackConfig();

config.plugins = config.plugins || [];
config.plugins.push(
  new NormalModuleReplacementPlugin(/\.\/socket\.js$/, (resource) => {
    if (!resource.context?.includes(`${path.sep}@rspack${path.sep}dev-server${path.sep}client`)) {
      return;
    }

    resource.request = path.resolve(__dirname, "patchedDevServerSocket.js");
  }),
);

module.exports = config;

const path = require("node:path");
const { NormalModuleReplacementPlugin } = require("@rspack/core");
const { generateRspackConfig } = require("shakapacker/rspack");

const config = generateRspackConfig();
const rspackDevServerClientContext = new RegExp(
  `(?:^|[\\\\/])@rspack[\\\\/]dev-server[\\\\/]client$`,
);

config.plugins = config.plugins || [];
config.plugins.push(
  new NormalModuleReplacementPlugin(/\.\/socket\.js$/, (resource) => {
    if (!rspackDevServerClientContext.test(path.normalize(resource.context || ""))) {
      return;
    }

    resource.request = path.resolve(__dirname, "patchedDevServerSocket.js");
  }),
);

module.exports = config;

// Lets the container tooling point the app at a different backend at build time
module.exports = ({ config }) => ({
  ...config,
  android: {
    ...config.android,
    // Firebase config downloaded from the Firebase console (see docs/push_notifications.md)
    ...( process.env.GOOGLE_SERVICES_FILE
      ? { googleServicesFile: process.env.GOOGLE_SERVICES_FILE }
      : {} )
  },
  extra: {
    ...config.extra,
    apiUrl: process.env.COLAB_API_URL || config.extra.apiUrl
  }
});

// Tests cover the platform-neutral auth layer, so no React Native preset is needed.
module.exports = {
  preset: "ts-jest",
  testEnvironment: "node",
  testMatch: ["**/__tests__/**/*.test.ts"],
  transform: {
    "^.+\\.tsx?$": ["ts-jest", { tsconfig: { strict: true, esModuleInterop: true, jsx: "react" }, diagnostics: false }]
  }
};

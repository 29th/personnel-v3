const path    = require("path")
const webpack = require("webpack")
const mode    = process.env.NODE_ENV === "development" ? "development" : "production"

module.exports = {
  mode,
  optimization: {
    moduleIds: "deterministic"
  },
  entry: {
    application: "./app/javascript/application.js",
    active_admin_custom: "./app/javascript/active_admin_custom.js"
  },
  output: {
    filename: "[name].js",
    sourceMapFilename: "[file].map",
    path: path.resolve(__dirname, "..", "..", "app/assets/builds"),
  },
  plugins: [
    new webpack.optimize.LimitChunkCountPlugin({
      maxChunks: 1
    })
  ]
}

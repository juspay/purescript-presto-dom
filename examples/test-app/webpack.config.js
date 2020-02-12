var path = require('path');
var plugins = [];

module.exports = {
    mode: "development",
    entry: {
        index: "./index.js",
        lib: "./lib.js"
    },
    output: {
        path: __dirname + "/dist",
        filename: "[name]_bundle.js",
        publicPath: '/dist/',
        sourceMapFilename: "index_bundle.map"
    },
    plugins: plugins,
    module: {
        rules: [
            {
              test: /\.m?js$/,
              exclude: /(node_modules|bower_components)/,
              use: {
                loader: 'babel-loader',
                options: {
                  presets: ['@babel/preset-env']
                }
              }
            }
        ]
    },
    performance : {
        hints : false
    },
    devServer: {
        host: "0.0.0.0",
        inline: false,
        disableHostCheck: true,
        port: 8081
    }
}
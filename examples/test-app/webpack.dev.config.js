var path = require('path');
var webpack = require('webpack')

var plugins = [
];

module.exports = {
  devtool: "cheap-module-inline-source-map",
  entry: ["./index_bundle.js"],
  output: {
    path: __dirname + "/dist",
    filename: "index_bundle.js",
    publicPath: '/dist/',
    sourceMapFilename: "index_bundle.js.map"
  },
  plugins: plugins,
  module: {
    rules : [
      {
	test: /\.purs$/,
	use: [
	  {
	    loader: 'purs-loader',
	    options: {
	      src: [
		'bower_components/purescript-*/src/**/*.purs',
		'src/**/*.purs'
	      ],
	      bundle: false,
	      psc: 'psa',
	      pscArgs: {
		censorWarnings: true,
		censorSrc: true,
		censorLib: true,
		sourceMaps: true
	      },
	      pscIde: true
	    }
	  }
	]
      }
    ]
  },
  devServer: {
      port: 8081,
      host: "0.0.0.0",
      inline: false
  }
}

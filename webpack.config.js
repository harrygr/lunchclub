module.exports = {
	entry: './ui/index.ts',
	output: {
		path: `${__dirname}/priv/static/js`,
		filename: 'bundle.js'
	},
	module: {
		rules: [
		{
			test: /\.tsx?$/,
			loader: 'ts-loader',
			exclude: /node_modules/,
		}
		]
	},
	resolve: {
		extensions: [".tsx", ".ts", ".js"]
	}
}

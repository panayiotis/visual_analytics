const environment = require('./environment')
uglifyjs = environment.plugins.get('UglifyJs')
uglifyjs.options.compress.comparisons = false
uglifyjs.options.mangle = true//false
console.log(uglifyjs.options)
module.exports = environment.toWebpackConfig()

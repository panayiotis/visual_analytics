const merge = require('webpack-merge')
const environment = require('./environment')
const customConfig = require('./custom')

//module.exports = environment.toWebpackConfig()
module.exports = merge(environment.toWebpackConfig(), customConfig)

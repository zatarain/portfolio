const path = require('path')

module.exports = ({ config }) => {
  // a bunch of other rules here

  config.resolve.modules = [
    path.resolve(__dirname, '..', 'src'),
    'node_modules',
  ]

  // Alternately, for an alias:
  config.resolve.alias = {
    '#styles': path.resolve(__dirname, '..', 'src', 'styles')
  }

  return config
}

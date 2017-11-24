const fs = require('fs')
const mustache = require('mustache')

module.exports = function (filePath, data) {
  const template = fs.readFileSync(filePath, 'utf8')
  return mustache.render(template, data)
}

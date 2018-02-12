process.argv.splice(0, 2)
console.log(process.argv)

const replace = require('replace-in-file')
replace.sync({
  files: process.argv[0],
  from: / +\/\/.+\n/gm,
  to () { return '\n' },
})
replace.sync({
  files: process.argv[0],
  from: /\/\*\*.*\n*(\s*\*.*\n*)*/gm,
  to: ''
})
replace.sync({
  files: process.argv[0],
  from: /\n\n+/gm,
  to () { return '\n' },
})
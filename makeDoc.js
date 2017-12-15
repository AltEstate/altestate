const { CONTRACT } = process.env
const json = require(`./build/contracts/${CONTRACT}.json`)

const contract = json.contractName
const abi = json.abi

function w(exp) {
  console.log(exp)
}

function l(exp) {
  if (exp)
    w(exp)
  w('')
}


const arg = Array(10).fill(' ').join('')
const argTypesData = {
  uint256: 1000000000000,
  string: 'Sample String',
  address: '0xc569011652c8206daf01775a01e4ba0ddb25dddf',
  bytes: '0xfffffffff000000aaaaaaaa',
  bool: true
}

function name(field, prefix) {
  l(`### ${prefix}: \`${field.name}\``)
}
function outputs(field) {
  if (field.outputs && field.outputs.length > 0) {
    if (field.outputs.length === 1) {
      l(`**Возвращает:** \`${field.outputs[0].type}\``)
    } else {
      l('**Возвращает:**')
      w('```')
      field.outputs.forEach(input => {
        const name = (input.name.split('_').join('') + arg).slice(0, 10)
        const type = input.type
        w(`${name} : ${type}`)
      })
      w('```')
    }
  }
}

function inputs(field) {
  if (field.inputs && field.inputs.length > 0) {
    l('**Аргументы:**')
    w('```')
    field.inputs.forEach(input => {
      const name = (input.name.split('_').join('') + arg).slice(0, 10)
      const type = input.type
      w(`${name} : ${type}`)
    })
    w('```')
  }
}

function eventFields(field) {
  if (field.inputs && field.inputs.length > 0) {
    l('**Поля:**')
    w('```')
    field.inputs.forEach(input => {
      const name = (input.name.split('_').join('') + arg).slice(0, 10)
      const type = (input.type + arg).slice(0, 7)
      const indexed = input.indexed ? '[indexed]' : ''
      w(`${name} : ${type} ${indexed}`)
    })
    w('```')
  }
}

function request(field) {
  let argsSample = []
  if (field.inputs && field.inputs.length > 0) {
    argsSample = field.inputs.map(input => argTypesData[input.type])
  }
  l('**Пример запроса:**')
  w(`\`\`\`
POST /contract
{
  "contract": "${contract}",
  "method": "${field.name}",
  "at": "0x....",
  "args": ${JSON.stringify(argsSample, null, 4)}
}
\`\`\``) 
}

function selectAll(ast, selector) {
  return ast.children.filter(node => node.name === selector)
}
function select(ast, selector) {
  return selectAll(ast, selector)[0]
}

function childNames(ast) {
  return ast.children.map(node => node.name)
}

l('## Чтение данных')
abi.filter(field => field.constant).forEach(field => {
  name(field, 'Вызов')
  l(`${field.name} isn't documentated yet..`)
  outputs(field)
  inputs(field)
  request(field)
})
l('## Запись данных')
abi.filter(field => !field.constant).forEach(field => {
  name(field, 'Метод')
  l(`${field.name} isn't documentated yet..`)
  outputs(field)
  inputs(field)
  request(field)
})
l('## Журналы событий')
abi.filter(field => field.type === 'event').forEach(field => {
  name(field, 'Событие')
  l(`${field.name} isn't documentated yet..`)
  eventFields(field)
  // request(field)
})

// let ast = json.ast
// let indent = 0

// function dumpAst(ast, indent = 0) {
//   console.log(Array(indent * 2).fill(' ').join(' ') + (ast.name + '                     ').slice(0, 15) + ':' + 
//   if(ast.children)
//     ast.children.forEach(child => dumpAst(child, indent + 1))
// }

// dumpAst(ast)

// ast = select(ast, 'ContractDefinition')
// ast = select(ast, 'FunctionDefinition')
// console.log(childNames(ast))



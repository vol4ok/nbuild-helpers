$ = global.$ or false

unless $
  $ = require('core.js')
  $.ext(require('fs'))
  $.ext(require('path'))
  $.ext(require('util'))
  $.ext(require('child_process'))

{ASTWalker, Syntax} = require('./ast-walker')

class ASTDepManager extends ASTWalker

  constructor: (options) ->
    super

  CallExpression: (node) ->
    target = false
    if node.callee.type is Syntax.Identifier
      target = node.callee
    else if node.callee.type is Syntax.MemberExpression and 
      node.callee.object.type is Syntax.Identifier and
      node.callee.property.type is Syntax.Identifier 
        if node.callee.property.name is "call"
          target = node.callee.object
        else if node.callee.property.name is "apply"
          target = node.callee.object
    if target
      if target.name is 'require'
        target.name = "$.bind"
      
    node = super(node)
    return node

class ASTNamespaceWrapper extends ASTWalker

  constructor: (options) ->
    super
    @names = if $.isArray(options.name) 
    then options.name 
    else [options.name]

  Program: (node) ->
    node = super(node)
    node.body = @wrap(node.body)
    return node

  wrap: (body) ->
    args = []
    if @names.length > 0
      arg = {type: "ArrayExpression", elements: []}
      for name in @names
        arg.elements.push({type: "Literal", value: name})
      args.push(arg)
    arg = 
      type: "FunctionExpression"
      id: null
      params: [
        type: "Identifier"
        name: "module"
      ,
        type: "Identifier"
        name: "exports"
      ]
      body: 
        type: "BlockStatement"
        body: body
    args.push(arg)
    return [ 
      type: "ExpressionStatement"
      expression: 
        type: "CallExpression"
        callee: 
          type: "MemberExpression"
          computed: no
          object: 
            type: "Identifier"
            name: "$"
          property: 
            type: "Identifier"
            name: "ns"
        arguments: args
      ]


class ASTCoffeeScriptReplacer extends ASTWalker
  constructor: (options) ->
    super
    @delete = []

  on_walkComplete: (node) ->
    while @delete.length > 0
      path = @delete.pop()
      if m = /^(.+)\[(\d+)\]$/.exec(path)
        a = @get(node, m[1])
        a.remove(parseInt(m[2],10))
        #console.log "delete".red, path, a.length
        if a.length is 0
          parent = /^(.*\[(\d+)\])->.+$/.exec(path)[1]
          @delete.push(parent)
          #console.log "push".magenta, parent
    return node

  FunctionDeclaration: (node) ->
    return super(node)

  FunctionExpression: (node) -> 
    return super(node)

  VariableDeclarator: (node) ->
    if node.id and /__(hasProp|extends|indexOf|slice|bind)/.test(node.id.name)
      @delete.push(@path())
      return node
    super(node)

  CallExpression: (node) ->
    target = false
    if node.callee.type is Syntax.Identifier
      target = node.callee
    else if node.callee.type is Syntax.MemberExpression and 
      node.callee.object.type is Syntax.Identifier and
      node.callee.property.type is Syntax.Identifier 
        if node.callee.property.name is "call"
          target = node.callee.object
        else if node.callee.property.name is "apply"
          target = node.callee.object
    if target
      if target.name is '__bind'
        target.name = "$.bind"
      else if target.name is '__extends'
        target.name = "$.inherit"
      else if target.name is '__hasProp'
        target.name = "$.hasProp"
      else if target.name is '__indexOf'
        target.name = "$.indexOf"
      else if target.name is '__slice'
        target.name = "$.slice"
    node = super(node)
    return node

exports extends {ASTDepManager, ASTNamespaceWrapper, ASTCoffeeScriptReplacer}
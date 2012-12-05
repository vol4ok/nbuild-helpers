Syntax =
  AssignmentExpression: 'AssignmentExpression'
  ArrayExpression: 'ArrayExpression'
  BlockStatement: 'BlockStatement'
  BinaryExpression: 'BinaryExpression'
  BreakStatement: 'BreakStatement'
  CallExpression: 'CallExpression'
  CatchClause: 'CatchClause'
  ConditionalExpression: 'ConditionalExpression'
  ContinueStatement: 'ContinueStatement'
  DoWhileStatement: 'DoWhileStatement'
  DebuggerStatement: 'DebuggerStatement'
  EmptyStatement: 'EmptyStatement'
  ExpressionStatement: 'ExpressionStatement'
  ForStatement: 'ForStatement'
  ForInStatement: 'ForInStatement'
  FunctionDeclaration: 'FunctionDeclaration'
  FunctionExpression: 'FunctionExpression'
  Identifier: 'Identifier'
  IfStatement: 'IfStatement'
  Literal: 'Literal'
  LabeledStatement: 'LabeledStatement'
  LogicalExpression: 'LogicalExpression'
  MemberExpression: 'MemberExpression'
  NewExpression: 'NewExpression'
  ObjectExpression: 'ObjectExpression'
  Program: 'Program'
  Property: 'Property'
  ReturnStatement: 'ReturnStatement'
  SequenceExpression: 'SequenceExpression'
  SwitchStatement: 'SwitchStatement'
  SwitchCase: 'SwitchCase'
  ThisExpression: 'ThisExpression'
  ThrowStatement: 'ThrowStatement'
  TryStatement: 'TryStatement'
  UnaryExpression: 'UnaryExpression'
  UpdateExpression: 'UpdateExpression'
  VariableDeclaration: 'VariableDeclaration'
  VariableDeclarator: 'VariableDeclarator'
  WhileStatement: 'WhileStatement'
  WithStatement: 'WithStatement'


class ASTWalker

  constructor: (options = {}) ->
    @on_walk = options.walk if options.walk?
    @_stack = []
    @_path = []

  walk: (node, path = false) ->
    return node unless node
    @_stack.push(node)
    @_path.push(path) if path
    node = @on_walk.call(this, node) if typeof @on_walk is 'function'
    node = @[node.type](node)
    @_path.pop() if path
    @_stack.pop()
    node = @on_walkComplete(node) if @_stack.length is 0
    return node

  on_walkComplete: (node) -> return node

  path: -> @_path.join('->')
  parent: -> @_stack[@_stack.length - 2] or null
  depth: -> @_stack.length

  get: (node, path) ->
    path = path.split('->') if typeof path is 'string'
    for p in path
      if /(\S+)\[(\d+)\]/.test(p)
        node = node[RegExp.$1][parseInt(RegExp.$2,10)]
      else
        node = node[p]
    return node

  # interface AssignmentExpression <: Expression
  #   type: "AssignmentExpression";
  #   operator: AssignmentOperator;
  #   left: Expression;
  #   right: Expression;
  AssignmentExpression: (node) ->
    node.left = @walk(node.left, "left")
    node.right = @walk(node.right, "right")
    return node


  # interface ArrayExpression <: Expression
  #   type: "ArrayExpression";
  #   elements: [ Expression | null ];
  ArrayExpression: (node) ->
    for el,i in node.elements
      node.elements[i] = @walk(el, "elements[#{i}]")
    return node


  # interface BlockStatement <: Statement
  #   type: "BlockStatement";
  #   body: [ Statement ];
  BlockStatement: (node) ->
    for el,i in node.body
      node.body[i] = @walk(el, "body[#{i}]")
    return node


  # interface BinaryExpression <: Expression
  #   type: "BinaryExpression";
  #   operator: BinaryOperator;
  #   left: Expression;
  #   right: Expression;
  BinaryExpression: (node) ->
    @walk(node.left, "left")
    @walk(node.right, "right")
    return node


  # interface BreakStatement <: Statement
  #   type: "BreakStatement";
  #   label: Identifier | null;
  BreakStatement: (node) ->
    node.label = @walk(node.label, "label")
    return node


  # interface CallExpression <: Expression
  #   type: "CallExpression";
  #   callee: Expression;
  #   arguments: [ Expression ];
  CallExpression: (node) ->
    node.callee = @walk(node.callee, "callee")
    for el,i in node.arguments
      node.arguments[i] = @walk(el, "arguments[#{i}]")
    return node


  # interface CatchClause <: Node
  #   type: "CatchClause";
  #   param: Pattern;
  #   guard: Expression | null;
  #   body: BlockStatement;
  CatchClause: (node) ->
    node.param = @walk(node.param, "param")
    node.body  = @walk(node.body, "body")
    return node


  # interface ConditionalExpression <: Expression
  #   type: "ConditionalExpression";
  #   test: Expression;
  #   alternate: Expression;
  #   consequent: Expression;
  ConditionalExpression: (node) ->
    node.test       = @walk(node.test, "test")
    node.alternate  = @walk(node.alternate, "alternate")
    node.consequent = @walk(node.consequent, "consequent")
    return node


  # interface ContinueStatement <: Statement
  #   type: "ContinueStatement";
  #   label: Identifier | null;
  ContinueStatement: (node) ->
    node.label = @walk(node.label, "label")
    return node



  # interface DoWhileStatement <: Statement
  #   type: "DoWhileStatement";
  #   body: Statement;
  #   test: Expression;
  DoWhileStatement: (node) ->
    node.body = @walk(node.body, "body")
    node.test = @walk(node.test, "test")
    return node


  DebuggerStatement: (node) -> node


  EmptyStatement: (node) -> node


  # interface ExpressionStatement <: Statement {
  #   type: "ExpressionStatement";
  #   expression: Expression;
  ExpressionStatement: (node) ->
    node.expression = @walk(node.expression, "expression")
    return node


  # interface ForStatement <: Statement {
  #   type: "ForStatement";
  #   init: VariableDeclaration | Expression | null;
  #   test: Expression | null;
  #   update: Expression | null;
  #   body: Statement;
  ForStatement: (node) ->
    node.init   = @walk(node.init, "init")
    node.test   = @walk(node.test, "test")
    node.update = @walk(node.update, "update")
    node.body   = @walk(node.body, "body")
    return node


  # interface ForInStatement <: Statement {
  #   type: "ForInStatement";
  #   left: VariableDeclaration |  Expression;
  #   right: Expression;
  #   body: Statement;
  #   each: boolean;
  ForInStatement: (node) ->
    node.left  = @walk(node.left, "left")
    node.right = @walk(node.right, "right")
    node.body  = @walk(node.body, "body")
    return node



  # interface FunctionDeclaration <: Function, Declaration {
  #   type: "FunctionDeclaration";
  #   id: Identifier;
  #   params: [ Pattern ];
  #   defaults: [ Expression ];
  #   rest: Identifier | null;
  #   body: BlockStatement | Expression;
  #   generator: boolean;
  #   expression: boolean;
  FunctionDeclaration: (node) ->
    node.id  = @walk(node.id, "id")
    for el,i in node.params
      node.params[i] = @walk(el, "params[#{i}]")
    # for el,i in node.defaults
    #   node.defaults[i] = @walk(el)
    node.rest = @walk(node.rest, "rest")
    node.body = @walk(node.body, "body")
    return node


  # interface FunctionExpression <: Function, Expression {
  #   type: "FunctionExpression";
  #   id: Identifier | null;
  #   params: [ Pattern ];
  #   defaults: [ Expression ];
  #   rest: Identifier | null;
  #   body: BlockStatement | Expression;
  #   generator: boolean;
  #   expression: boolean;
  FunctionExpression: (node) ->
    node.id = @walk(node.id, "id")
    for el,i in node.params
      node.params[i] = @walk(el, "params[#{i}]")
    # for el,i in node.defaults
    #   node.defaults[i] = @walk(el)
    node.rest = @walk(node.rest, "rest")
    node.body = @walk(node.body, "body")
    return node


  Identifier: (node) ->
    return node


  # interface IfStatement <: Statement {
  #   type: "IfStatement";
  #   test: Expression;
  #   consequent: Statement;
  #   alternate: Statement | null;
  IfStatement: (node) ->
    node.test       = @walk(node.test, "test")
    node.consequent = @walk(node.consequent, "consequent")
    node.alternate  = @walk(node.alternate, "alternate")
    return node


  Literal: (node) ->
    return node


  # interface LabeledStatement <: Statement {
  #   type: "LabeledStatement";
  #   label: Identifier;
  #   body: Statement;
  LabeledStatement: (node) ->
    node.label = @walk(node.label, "label")
    node.body  = @walk(node.body, "body")
    return node


  # interface LogicalExpression <: Expression {
  #   type: "LogicalExpression";
  #   operator: LogicalOperator;
  #   left: Expression;
  #   right: Expression;
  LogicalExpression: (node) ->
    node.left  = @walk(node.left, "left")
    node.right = @walk(node.right, "right")
    return node


  # interface MemberExpression <: Expression {
  #   type: "MemberExpression";
  #   object: Expression;
  #   property: Identifier | Expression;
  MemberExpression: (node) ->
    node.object   = @walk(node.object, "object")
    node.property = @walk(node.property, "property")
    return node


  # interface NewExpression <: Expression {
  #   type: "NewExpression";
  #   callee: Expression;
  #   arguments: [ Expression ] | null;
  NewExpression: (node) ->
    node.callee = @walk(node.callee, "callee")
    for el,i in node.arguments
      node.arguments[i] = @walk(el, "arguments[#{i}]")
    return node


  # interface ObjectExpression <: Expression {
  #   type: "ObjectExpression";
  #   properties: [ Property ];
  ObjectExpression: (node) ->
    for el,i in node.properties
      node.properties[i] = @walk(el, "properties[#{i}]")
    return node


  # interface Program <: Node {
  #   type: "Program";
  #   body: [ Statement ];
  Program: (node) ->
    for el,i in node.body
      node.body[i] = @walk(el, "body[#{i}]")
    return node


  # interface Property
  #   key: Literal | Identifier,
  #   value: Expression,
  #   kind: "init" | "get" | "set" }
  Property: (node) ->
    node.key   = @walk(node.key, "key")
    node.value = @walk(node.value, "value")
    return node


  # interface ReturnStatement <: Statement {
  #   type: "ReturnStatement";
  #   argument: Expression | null;
  ReturnStatement: (node) ->
    node.argument = @walk(node.argument, "argument")
    return node


  # interface SequenceExpression <: Expression {
  #   type: "SequenceExpression";
  #   expressions: [ Expression ];
  SequenceExpression: (node) ->
    for el,i in node.expressions
      node.expressions[i] = @walk(el, "expressions[#{i}]")
    return node


  # interface SwitchStatement <: Statement {
  #   type: "SwitchStatement";
  #   discriminant: Expression;
  #   cases: [ SwitchCase ];
  #   lexical: boolean;
  SwitchStatement: (node) ->
    node.discriminant = @walk(node.discriminant, "discriminant")
    for el,i in node.cases
      node.cases[i] = @walk(el, "cases[#{i}]")
    return node


  # interface SwitchCase <: Node {
  #   type: "SwitchCase";
  #   test: Expression | null;
  #   consequent: [ Statement ];
  SwitchCase: (node) ->
    node.test = @walk(node.test, "test")
    for el,i in node.consequent
      node.consequent[i] = @walk(el, "consequent[#{i}]")
    return node

  ThisExpression: (node) ->
    return node

  # interface ThrowStatement <: Statement {
  #   type: "ThrowStatement";
  #   argument: Expression;
  ThrowStatement: (node) ->
    node.argument = @walk(node.argument, "argument")
    return node

  # interface TryStatement <: Statement {
  #   type: "TryStatement";
  #   block: BlockStatement;
  #   handlers: [ CatchClause ];
  #   finalizer: BlockStatement | null;
  TryStatement: (node) ->
    node.block = @walk(node.block, "block")
    for el,i in node.handlers
      node.handlers[i] = @walk(el, "handlers[#{i}]")
    node.finalizer = @walk(node.finalizer, "finalizer")
    return node


  # interface UnaryExpression <: Expression {
  #   type: "UnaryExpression";
  #   prefix: boolean;
  #   argument: Expression;
  UnaryExpression: (node) ->
    node.argument = @walk(node.argument, "argument")
    return node


  # interface UpdateExpression <: Expression {
  #   type: "UpdateExpression";
  #   argument: Expression;
  #   prefix: boolean;
  UpdateExpression: (node) ->
    node.argument = @walk(node.argument, "argument")
    return node

  # interface VariableDeclaration <: Declaration {
  #   type: "VariableDeclaration";
  #   declarations: [ VariableDeclarator ];
  #   kind: "var" | "let" | "const";
  VariableDeclaration: (node) ->
    for el,i in node.declarations
      node.declarations[i] = @walk(el, "declarations[#{i}]")
    return node

  # interface VariableDeclarator <: Node {
  #   type: "VariableDeclarator";
  #   id: Pattern;
  #   init: Expression | null;
  VariableDeclarator: (node) ->
    node.id   = @walk(node.id, "id")
    node.init = @walk(node.init, "init")
    return node

  # interface WhileStatement <: Statement {
  #   type: "WhileStatement";
  #   test: Expression;
  #   body: Statement;
  WhileStatement: (node) ->
    node.test = @walk(node.test, "test")
    node.body = @walk(node.body, "body")
    return node

  # interface WithStatement <: Statement {
  #   type: "WithStatement";
  #   object: Expression;
  #   body: Statement;
  WithStatement: (node) ->
    node.object = @walk(node.object, "object")
    node.body   = @walk(node.body, "body")
    return node

exports.ASTWalker = ASTWalker
exports.Syntax = Syntax
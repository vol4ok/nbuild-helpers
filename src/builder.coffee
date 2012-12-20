BUILD_ENV = process.env["BUILD_ENV"]
require BUILD_ENV if BUILD_ENV

$ = global.$ or false
BUILD_DIR = global.BUILD_DIR or __dirname
REDIS_DB_INDEX = REDIS_DB_INDEX or 0

unless $
  $ = require('core.js')
  $.ext(require('fs'))
  $.ext(require('path'))
  $.ext(require('util'))
  $.ext(require('child_process'))

Redis     = require("redis")
coffee    = require("coffee-script")
stylus    = require("stylus")
hogan     = require("hogan.js")
ck        = require("./coffeekup")
esprima   = require("esprima")
escodegen = require("escodegen")

{ ASTDepManager
  ASTNamespaceWrapper
  ASTCoffeeScriptReplacer 
} = require "#{BUILD_DIR}/ast/ast-transformers"

COFFEE    = "coffee"
STYLUS    = "stylus"
COFFEEKUP = "coffeekup"
MUSTACHE  = "mustache"
JSTF      = "js"
HTML      = "html"


TRANSFORM_COFFEESCRIPT_REPLACER = "cs_replacer"
TRANSFORM_NAMESPACE_WRAPPER     = "ns_wrapper"

AST_TRANSFORMERS = {}

AST_TRANSFORMERS[TRANSFORM_COFFEESCRIPT_REPLACER] = (ast, opt) -> 
  (new ASTCoffeeScriptReplacer()).walk(ast)

AST_TRANSFORMERS[TRANSFORM_NAMESPACE_WRAPPER] = (ast, opt) -> 
  (new ASTNamespaceWrapper(name: opt.namespace)).walk(ast)


basename = (path) -> /^(?:.*\/)?(.+?)(?:\.[^\.]*)?$/.exec(path)[1]


_createRedisClient = (opt = {}) ->
  opt.port  ?= 6379
  opt.index ?= 0
  dbfs = Redis.createClient(opt.port)
  dbfs.select(opt.index)
  return dbfs

s_dbfs = null 

initDBFS = -> s_dbfs = _createRedisClient(index: REDIS_DB_INDEX)
freeDBFS = -> if s_dbfs then s_dbfs.end(); s_dbfs = null 
is_dbfs = (path) -> $.startsWith(path, "dbfs:")



read = (src, done) ->
  if is_dbfs(src)
    s_dbfs.get(src, done)
  else
    $.readFile src, 'utf-8', done

write = (dst, str, done) ->
  if is_dbfs(dst)
    s_dbfs.set(dst, str, done)
  else
    $.writeFile dst, str, "utf-8", done


# str -> str functions

ss_coffee = (str, opt, done) ->
  done(null, coffee.compile(str, opt))

ss_stylus = (str, opt, done) ->
  stylus.render str, opt, done

ss_html = (str, opt, done) ->
  done(null, str)

ss_js = (str, opt, done) ->
  ast = esprima.parse(str, opt)
  if opt.transform
    for tfname in opt.transform
      ast = AST_TRANSFORMERS[tfname](ast, opt)
  str = escodegen.generate(ast)
  done(null, str)

ss_mustache = (str, opt, done) ->
  try
    str = hogan.compile(str, opt)
    unless opt.asString
      str = str.render(opt.locals, opt.partials)
  catch err
    return done(err)
  done(null, str)

ss_coffeekup = (str, opt, done) ->
  try
    str = ck.render(str, opt)
  catch err
    return done(err)
  done(null, str)

ss_merge = (strs, opt, done) ->
  sep = opt.separator or "\n\n"
  res = ""
  for str in strs
    res += $.trim(str) + sep
  done(null, res)


# file -> str functions

fs_coffee = (src, opt, done) ->
  $.chain [
    (cb) -> read(src, cb)
    (err, str) -> ss_coffee(str, opt, done)
  ], done


fs_stylus = (src, opt, done) ->
  opt.filename = src unless opt.filename
  $.chain [
    (cb) -> read(src, cb)
    (err, str) -> ss_stylus(str, opt, done)
  ], done

fs_html = (src, opt, done) ->
  $.chain [
    (cb) -> read(src, cb)
    (err, str) -> ss_html(str, opt, done)
  ], done

fs_js = (src, opt, done) ->
  $.chain [
    (cb) -> read(src, cb)
    (err, str) -> ss_js(str, opt, done)
  ], done

fs_mustache = (src, opt, done) ->
  $.chain [
    (cb) -> read(src, cb)
    (err, str) -> ss_mustache(str, opt, done)
  ], done

fs_coffeekup = (src, opt, done) ->
  $.chain [
    (cb) -> read(src, cb)
    (err, str) -> ss_coffeekup(str, opt, done)
  ], done

fs_merge = (srcs, opt, done) ->
  $.chain [
    (cb) -> $.asyncMap srcs, read, cb
    (err, strs) -> ss_merge(strs, opt, done)
  ], done

# str -> file functions

sf_coffee = (str, dst, opt, done) ->
  $.chain [
    (cb) -> ss_coffee(str, opt, cb)
    (err, str) -> write(dst, str, done)
  ], done

sf_stylus = (str, dst, opt, done) ->
  $.chain [
    (cb) -> ss_stylus(str, opt, cb)
    (err, str) -> write(dst, str, done)
  ], done

sf_html = (str, dst, opt, done) ->
  $.chain [
    (cb) -> ss_html(str, opt, cb)
    (err, str) -> write(dst, str, done)
  ], done

sf_js = (str, dst, opt, done) ->
  $.chain [
    (cb) -> ss_js(str, opt, cb)
    (err, str) -> write(dst, str, done)
  ], done

sf_mustache = (str, dst, opt, done) ->
  $.chain [
    (cb) -> ss_mustache(str, opt, cb)
    (err, str) -> write(dst, str, done)
  ], done

sf_coffeekup = (str, dst, opt, done) ->
  $.chain [
    (cb) -> ss_coffeekup(str, opt, cb)
    (err, str) -> write(dst, str, done)
  ], done

sf_merge = (strs, dst, opt, done) ->
  $.chain [
    (cb) -> ss_merge(strs, opt, cb)
    (err, str) -> write(dst, str, done)
  ], done




ff_copy = (src, dst, opt, done) ->
  $.chain [
    (cb) -> read(src, cb)
    (err, str) -> write(dst, str, done)
  ], done

ff_coffee = (src, dst, opt, done) ->
  $.chain [
    (cb) -> fs_coffee(src, opt, cb)
    (err, str) -> write(dst, str, done)
  ], done

ff_stylus = (src, dst, opt, done) ->
  $.chain [
    (cb) -> fs_stylus(src, opt, cb)
    (err, str) -> write(dst, str, done)
  ], done

ff_html = (src, dst, opt, done) ->
  $.chain [
    (cb) -> fs_html(src, opt, cb)
    (err, str) -> write(dst, str, done)
  ], done

ff_js = (src, dst, opt, done) ->
  $.chain [
    (cb) -> fs_js(src, opt, cb)
    (err, str) -> write(dst, str, done)
  ], done

ff_mustache = (src, dst, opt, done) ->
  $.chain [
    (cb) -> fs_mustache(src, opt, cb)
    (err, str) -> write(dst, str, done)
  ], done

ff_coffeekup = (src, dst, opt, done) ->
  $.chain [
    (cb) -> fs_coffeekup(src, opt, cb)
    (err, str) -> write(dst, str, done)
  ], done

ff_merge = (srcs, dst, opt, done) ->
  $.chain [
    (cb) -> fs_merge(srcs, opt, cb)
    (err, str) -> write(dst, str, done)
  ], done

make = (targets) ->

module.exports = {

  initDBFS
  freeDBFS

  is_dbfs
  basename
  read
  write
  
  ss_coffee
  ss_stylus
  ss_mustache
  ss_coffeekup
  ss_merge
  ss_js
  ss_html

  fs_coffee
  fs_stylus
  fs_mustache
  fs_coffeekup
  fs_merge
  fs_js
  fs_html

  sf_coffee
  sf_stylus
  sf_mustache
  sf_coffeekup
  sf_merge
  sf_js
  sf_html
  
  ff_coffee
  ff_stylus
  ff_mustache
  ff_coffeekup
  ff_merge
  ff_js
  ff_html

  ff_copy

  COFFEE
  STYLUS
  COFFEEKUP
  MUSTACHE
  JSTF

  TRANSFORM_COFFEESCRIPT_REPLACER
  TRANSFORM_NAMESPACE_WRAPPER
}
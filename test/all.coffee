
chai = require("chai")
expect = chai.expect
should = chai.should()

FIXTURES_DIR    = __dirname + "/fixtures"
TEMP_DIR        = __dirname + "/fixtures"
OUTPUT_PATH     = TEMP_DIR  + "/OUTPUT"

describe "builder", ->

  b  = require "../lib/builder"
  fs = require 'fs'

  describe "#ss_coffee", ->

    COFFEE_CODE_1   = fs.readFileSync "#{FIXTURES_DIR}/coffee-code-1.coffee", "utf-8"
    COFFEE_RESULT_1 = fs.readFileSync "#{FIXTURES_DIR}/COFFEE_RESULT_1", "utf-8"

    it "should have method #ss_coffee", ->
      expect(b).to.respondTo("ss_coffee")
      expect(b.ss_coffee).to.be.a("function")

    it "should compile coffee js code", (done) ->
      b.ss_coffee COFFEE_CODE_1, {bare: yes}, (err, str) ->
        expect(err).to.be.null
        f = Function(str)
        expect(f()).to.equal(COFFEE_RESULT_1)
        done()


  describe "#ss_stylus", ->

    STYLUS_CODE_1   = fs.readFileSync "#{FIXTURES_DIR}/stylus-code-1.styl", "utf-8"
    STYLUS_RESULT_1 = fs.readFileSync "#{FIXTURES_DIR}/STYLUS_RESULT_1", "utf-8"

    it "should have method #ss_stylus", ->
      expect(b).to.respondTo("ss_stylus")
      expect(b.ss_stylus).to.be.a("function")

    it "should compile stylus code", (done) ->
      b.ss_stylus STYLUS_CODE_1, {compress: yes}, (err, str) ->
        expect(err).to.be.null
        expect(str).to.have.string(STYLUS_RESULT_1)
        done()



  describe "#ss_html", ->

    HTML_CODE_1   = fs.readFileSync "#{FIXTURES_DIR}/html-1.html", "utf-8"
    HTML_RESULT_1 = fs.readFileSync "#{FIXTURES_DIR}/HTML_RESULT_1", "utf-8"
    HTML_RESULT_2 = fs.readFileSync "#{FIXTURES_DIR}/HTML_RESULT_2", "utf-8"

    it "should have method #ss_html", ->
      expect(b).to.respondTo("ss_html")
      expect(b.ss_html).to.be.a("function")

    it "should compile html code", (done) ->
      b.ss_html HTML_CODE_1, {compress: no}, (err, str) ->
        expect(err).to.be.null
        expect(str).to.have.string(HTML_RESULT_1)
        #fs.writeFileSync "#{FIXTURES_DIR}/HTML_RESULT_1", str, "utf-8"
        done()


    it "should compile and compress html code", (done) ->
      b.ss_html HTML_CODE_1, {}, (err, str) ->
        expect(err).to.be.null
        expect(str).to.have.string(HTML_RESULT_2)
        #fs.writeFileSync "#{FIXTURES_DIR}/HTML_RESULT_2", str, "utf-8"
        done()

  describe "#ss_mustache", ->

    MUSTACHE_CODE_1 = fs.readFileSync "#{FIXTURES_DIR}/mustache-code-1.mu", "utf-8"
    MUSTACHE_LOCALS_1 = 
      world: "<b>world</b>"
      hash: [
        {item: "item1"}
        {item: "item2"}
        {item: "item3"}
      ]
    MUSTACHE_PARTIALS_1 = part: "<p>I'm partial!</p>"
    MUSTACHE_RESULT_1   = fs.readFileSync "#{FIXTURES_DIR}/MUSTACHE_RESULT_1", "utf-8"
    MUSTACHE_RESULT_2   = fs.readFileSync "#{FIXTURES_DIR}/MUSTACHE_RESULT_2", "utf-8"

    it "should have method #ss_mustache", ->
      expect(b).to.respondTo("ss_mustache")
      expect(b.ss_mustache).to.be.a("function")

    it "should compile mustache template code", (done) ->
      b.ss_mustache MUSTACHE_CODE_1, 
      locals: MUSTACHE_LOCALS_1
      partials: MUSTACHE_PARTIALS_1
      , (err, str) ->
        expect(err).to.be.null
        expect(str).to.have.string(MUSTACHE_RESULT_1)
        done()

    it "should compile mustache template to js code", (done) ->
      Template = require("hogan.js").Template
      b.ss_mustache MUSTACHE_CODE_1, asString: yes, (err, str) ->
        expect(err).to.be.null
        expect(str).to.have.string(MUSTACHE_RESULT_2)
        done()


  describe "#ss_coffeekup", ->

    COFFEEKUP_CODE_1   = fs.readFileSync "#{FIXTURES_DIR}/coffeekup-code-1.ck", "utf-8"
    COFFEEKUP_RESULT_1 = fs.readFileSync "#{FIXTURES_DIR}/COFFEEKUP_RESULT_1", "utf-8"

    it "should have method #ss_coffeekup", ->
      expect(b).to.respondTo("ss_coffeekup")
      expect(b.ss_coffeekup).to.be.a("function")

    it "should compile coffekup template", (done) ->
      Template = require("hogan.js").Template
      b.ss_coffeekup COFFEEKUP_CODE_1, {}, (err, str) ->
        expect(err).to.be.null
        expect(str).to.have.string(COFFEEKUP_RESULT_1)
        done()


  describe "#ss_merge", ->

    MERGE_CODE_1 = fs.readFileSync "#{FIXTURES_DIR}/merge-code-1.js", "utf-8"
    MERGE_CODE_2 = fs.readFileSync "#{FIXTURES_DIR}/merge-code-2.js", "utf-8"
    MERGE_RESULT_1 = fs.readFileSync "#{FIXTURES_DIR}/MERGE_RESULT_1", "utf-8"

    it "should have method #ss_coffee", ->
      expect(b).to.respondTo("ss_merge")
      expect(b.ss_merge).to.be.a("function")

    it "should merge javascript files", (done) ->
      b.ss_merge [MERGE_CODE_1, MERGE_CODE_2], {}, (err, str) ->
        expect(err).to.be.null
        expect(str).to.have.string(MERGE_RESULT_1)
        done()

  describe "#ss_js", ->

    JS_CODE_1 = fs.readFileSync "#{FIXTURES_DIR}/js-code-1.js", "utf-8"
    JS_RESULT_1 = fs.readFileSync "#{FIXTURES_DIR}/JS_RESULT_1", "utf-8"
    JS_RESULT_2 = fs.readFileSync "#{FIXTURES_DIR}/JS_RESULT_2", "utf-8"
    JS_RESULT_3 = fs.readFileSync "#{FIXTURES_DIR}/JS_RESULT_3", "utf-8"

    it "should have method #ss_js", ->
      expect(b).to.respondTo("ss_js")
      expect(b.ss_js).to.be.a("function")

    it "should compile javascript code", (done) ->
      b.ss_js JS_CODE_1, {}, (err, str) ->
        expect(err).to.be.null
        expect(str).to.have.string(JS_RESULT_1)
        done()

    it "should compile and transform javascript code", (done) ->
      b.ss_js JS_CODE_1, 
        transform: [b.TRANSFORM_COFFEESCRIPT_REPLACER, b.TRANSFORM_NAMESPACE_WRAPPER]
        namespace: "test"
        , (err, str) ->
          expect(err).to.be.null
          expect(str).to.have.string(JS_RESULT_2)
          done()

    it "should compile, transform and compress javascript code", (done) ->
      b.ss_js JS_CODE_1, 
        transform: [b.TRANSFORM_COFFEESCRIPT_REPLACER, b.TRANSFORM_NAMESPACE_WRAPPER]
        namespace: "test"
        compress: yes
        compressor: {warnings: no}
        , (err, str) ->
          expect(err).to.be.null
          #fs.writeFileSync "#{FIXTURES_DIR}/JS_RESULT_4", str, "utf-8"
          expect(str).to.have.string(JS_RESULT_3)
          done()




  describe "#fs_coffee", ->

    COFFEE_RESULT_1 = fs.readFileSync "#{FIXTURES_DIR}/COFFEE_RESULT_1", "utf-8"

    it "should have method #fs_coffee", ->
      expect(b).to.respondTo("fs_coffee")
      expect(b.fs_coffee).to.be.a("function")

    it "should compile coffee js code", (done) ->
      b.fs_coffee "#{FIXTURES_DIR}/coffee-code-1.coffee", {bare: yes}, (err, str) ->
        expect(err).to.be.null
        f = Function(str)
        expect(f()).to.equal(COFFEE_RESULT_1)
        done()


  describe "#fs_stylus", ->

    STYLUS_RESULT_1 = fs.readFileSync "#{FIXTURES_DIR}/STYLUS_RESULT_1", "utf-8"

    it "should have method #fs_stylus", ->
      expect(b).to.respondTo("fs_stylus")
      expect(b.fs_stylus).to.be.a("function")

    it "should compile stylus code", (done) ->
      b.fs_stylus "#{FIXTURES_DIR}/stylus-code-1.styl", {compress: yes}, (err, str) ->
        expect(err).to.be.null
        expect(str).to.have.string(STYLUS_RESULT_1)
        done()


  describe "#fs_mustache", ->

    MUSTACHE_LOCALS_1 = 
      world: "<b>world</b>"
      hash: [
        {item: "item1"}
        {item: "item2"}
        {item: "item3"}
      ]
    MUSTACHE_PARTIALS_1 = part: "<p>I'm partial!</p>"
    MUSTACHE_RESULT_1   = fs.readFileSync "#{FIXTURES_DIR}/MUSTACHE_RESULT_1", "utf-8"
    MUSTACHE_RESULT_2   = fs.readFileSync "#{FIXTURES_DIR}/MUSTACHE_RESULT_2", "utf-8"

    it "should have method #fs_mustache", ->
      expect(b).to.respondTo("fs_mustache")
      expect(b.fs_mustache).to.be.a("function")

    it "should compile mustache template code", (done) ->
      b.fs_mustache "#{FIXTURES_DIR}/mustache-code-1.mu", 
      locals: MUSTACHE_LOCALS_1
      partials: MUSTACHE_PARTIALS_1
      , (err, str) ->
        expect(err).to.be.null
        expect(str).to.have.string(MUSTACHE_RESULT_1)
        done()

    it "should compile mustache template to js code", (done) ->
      Template = require("hogan.js").Template
      b.fs_mustache "#{FIXTURES_DIR}/mustache-code-1.mu", asString: yes, (err, str) ->
        expect(err).to.be.null
        expect(str).to.have.string(MUSTACHE_RESULT_2)
        done()


  describe "#fs_coffeekup", ->

    COFFEEKUP_RESULT_1 = fs.readFileSync "#{FIXTURES_DIR}/COFFEEKUP_RESULT_1", "utf-8"

    it "should have method #fs_coffeekup", ->
      expect(b).to.respondTo("fs_coffeekup")
      expect(b.fs_coffeekup).to.be.a("function")

    it "should compile coffekup template", (done) ->
      Template = require("hogan.js").Template
      b.fs_coffeekup "#{FIXTURES_DIR}/coffeekup-code-1.ck", {}, (err, str) ->
        expect(err).to.be.null
        expect(str).to.have.string(COFFEEKUP_RESULT_1)
        done()


  describe "#fs_merge", ->

    MERGE_RESULT_1 = fs.readFileSync "#{FIXTURES_DIR}/MERGE_RESULT_1", "utf-8"

    it "should have method #ss_coffee", ->
      expect(b).to.respondTo("fs_merge")
      expect(b.fs_merge).to.be.a("function")

    it "should merge javascript files", (done) ->
      b.fs_merge ["#{FIXTURES_DIR}/merge-code-1.js", "#{FIXTURES_DIR}/merge-code-2.js"], {}, (err, str) ->
        expect(err).to.be.null
        expect(str).to.have.string(MERGE_RESULT_1)
        done()


  describe "#fs_js", ->

    JS_RESULT_1 = fs.readFileSync "#{FIXTURES_DIR}/JS_RESULT_1", "utf-8"
    JS_RESULT_2 = fs.readFileSync "#{FIXTURES_DIR}/JS_RESULT_2", "utf-8"

    it "should have method #fs_js", ->
      expect(b).to.respondTo("fs_js")
      expect(b.fs_js).to.be.a("function")

    it "should compile javascript code", (done) ->
      b.fs_js "#{FIXTURES_DIR}/js-code-1.js", {}, (err, str) ->
        expect(err).to.be.null
        # fs.writeFileSync "#{FIXTURES_DIR}/JS_RESULT_1", str, "utf-8"
        expect(str).to.have.string(JS_RESULT_1)
        done()

    it "should compile and transform javascript code", (done) ->
      b.fs_js "#{FIXTURES_DIR}/js-code-1.js", 
        transform: [b.TRANSFORM_COFFEESCRIPT_REPLACER, b.TRANSFORM_NAMESPACE_WRAPPER]
        namespace: "test"
        , (err, str) ->
          expect(err).to.be.null
           # fs.writeFileSync "#{FIXTURES_DIR}/JS_RESULT_2", str, "utf-8"
          expect(str).to.have.string(JS_RESULT_2)
          done()



  describe "#sf_coffee", ->

    COFFEE_CODE_1   = fs.readFileSync "#{FIXTURES_DIR}/coffee-code-1.coffee", "utf-8"
    COFFEE_RESULT_1 = fs.readFileSync "#{FIXTURES_DIR}/COFFEE_RESULT_1", "utf-8"

    it "should have method #sf_coffee", ->
      expect(b).to.respondTo("sf_coffee")
      expect(b.sf_coffee).to.be.a("function")

    it "should compile coffee js code", (done) ->
      b.sf_coffee COFFEE_CODE_1, OUTPUT_PATH, {bare: yes}, (err) ->
        expect(err).to.be.null
        str = fs.readFileSync(OUTPUT_PATH, "utf-8")
        fs.unlinkSync(OUTPUT_PATH)
        f = Function(str)
        expect(f()).to.equal(COFFEE_RESULT_1)
        done()


  describe "#sf_stylus", ->

    STYLUS_CODE_1   = fs.readFileSync "#{FIXTURES_DIR}/stylus-code-1.styl", "utf-8"
    STYLUS_RESULT_1 = fs.readFileSync "#{FIXTURES_DIR}/STYLUS_RESULT_1", "utf-8"

    it "should have method #sf_stylus", ->
      expect(b).to.respondTo("sf_stylus")
      expect(b.sf_stylus).to.be.a("function")

    it "should compile stylus code", (done) ->
      b.sf_stylus STYLUS_CODE_1, OUTPUT_PATH, {compress: yes}, (err) ->
        expect(err).to.be.null
        str = fs.readFileSync(OUTPUT_PATH, "utf-8")
        fs.unlinkSync(OUTPUT_PATH)
        expect(str).to.have.string(STYLUS_RESULT_1)
        done()


  describe "#sf_mustache", ->

    MUSTACHE_CODE_1 = fs.readFileSync "#{FIXTURES_DIR}/mustache-code-1.mu", "utf-8"
    MUSTACHE_LOCALS_1 = 
      world: "<b>world</b>"
      hash: [
        {item: "item1"}
        {item: "item2"}
        {item: "item3"}
      ]
    MUSTACHE_PARTIALS_1 = part: "<p>I'm partial!</p>"
    MUSTACHE_RESULT_1   = fs.readFileSync "#{FIXTURES_DIR}/MUSTACHE_RESULT_1", "utf-8"
    MUSTACHE_RESULT_2   = fs.readFileSync "#{FIXTURES_DIR}/MUSTACHE_RESULT_2", "utf-8"

    it "should have method #sf_mustache", ->
      expect(b).to.respondTo("sf_mustache")
      expect(b.sf_mustache).to.be.a("function")

    it "should compile mustache template code", (done) ->
      b.sf_mustache MUSTACHE_CODE_1, OUTPUT_PATH,  
      locals: MUSTACHE_LOCALS_1
      partials: MUSTACHE_PARTIALS_1
      , (err) ->
        expect(err).to.be.null
        str = fs.readFileSync(OUTPUT_PATH, "utf-8")
        fs.unlinkSync(OUTPUT_PATH)
        expect(str).to.have.string(MUSTACHE_RESULT_1)
        done()

    it "should compile mustache template to js code", (done) ->
      Template = require("hogan.js").Template
      b.sf_mustache MUSTACHE_CODE_1, OUTPUT_PATH, asString: yes, (err) ->
        expect(err).to.be.null
        str = fs.readFileSync(OUTPUT_PATH, "utf-8")
        fs.unlinkSync(OUTPUT_PATH)
        expect(str).to.have.string(MUSTACHE_RESULT_2)
        done()


  describe "#sf_coffeekup", ->

    COFFEEKUP_CODE_1   = fs.readFileSync "#{FIXTURES_DIR}/coffeekup-code-1.ck", "utf-8"
    COFFEEKUP_RESULT_1 = fs.readFileSync "#{FIXTURES_DIR}/COFFEEKUP_RESULT_1", "utf-8"

    it "should have method #sf_coffeekup", ->
      expect(b).to.respondTo("sf_coffeekup")
      expect(b.sf_coffeekup).to.be.a("function")

    it "should compile coffekup template", (done) ->
      Template = require("hogan.js").Template
      b.sf_coffeekup COFFEEKUP_CODE_1, OUTPUT_PATH, {}, (err) ->
        expect(err).to.be.null
        str = fs.readFileSync(OUTPUT_PATH, "utf-8")
        fs.unlinkSync(OUTPUT_PATH)
        expect(str).to.have.string(COFFEEKUP_RESULT_1)
        done()


  describe "#sf_merge", ->

    MERGE_CODE_1 = fs.readFileSync "#{FIXTURES_DIR}/merge-code-1.js", "utf-8"
    MERGE_CODE_2 = fs.readFileSync "#{FIXTURES_DIR}/merge-code-2.js", "utf-8"
    MERGE_RESULT_1 = fs.readFileSync "#{FIXTURES_DIR}/MERGE_RESULT_1", "utf-8"

    it "should have method #sf_coffee", ->
      expect(b).to.respondTo("sf_merge")
      expect(b.sf_merge).to.be.a("function")

    it "should merge javascript files", (done) ->
      b.sf_merge [MERGE_CODE_1, MERGE_CODE_2], OUTPUT_PATH, {}, (err) ->
        expect(err).to.be.null
        str = fs.readFileSync(OUTPUT_PATH, "utf-8")
        fs.unlinkSync(OUTPUT_PATH)
        expect(str).to.have.string(MERGE_RESULT_1)
        done()

  describe "#sf_js", ->

    JS_CODE_1 = fs.readFileSync "#{FIXTURES_DIR}/js-code-1.js", "utf-8"
    JS_RESULT_1 = fs.readFileSync "#{FIXTURES_DIR}/JS_RESULT_1", "utf-8"
    JS_RESULT_2 = fs.readFileSync "#{FIXTURES_DIR}/JS_RESULT_2", "utf-8"

    it "should have method #sf_js", ->
      expect(b).to.respondTo("sf_js")
      expect(b.sf_js).to.be.a("function")

    it "should compile javascript code", (done) ->
      b.sf_js JS_CODE_1, OUTPUT_PATH, {}, (err) ->
        expect(err).to.be.null
        str = fs.readFileSync(OUTPUT_PATH, "utf-8")
        fs.unlinkSync(OUTPUT_PATH)
        expect(str).to.have.string(JS_RESULT_1)
        done()

    it "should compile and transform javascript code", (done) ->
      b.sf_js JS_CODE_1, OUTPUT_PATH, 
        transform: [b.TRANSFORM_COFFEESCRIPT_REPLACER, b.TRANSFORM_NAMESPACE_WRAPPER]
        namespace: "test"
        , (err) ->
          expect(err).to.be.null
          str = fs.readFileSync(OUTPUT_PATH, "utf-8")
          fs.unlinkSync(OUTPUT_PATH)
          expect(str).to.have.string(JS_RESULT_2)
          done()





  describe "#ff_coffee", ->

    COFFEE_RESULT_1 = fs.readFileSync "#{FIXTURES_DIR}/COFFEE_RESULT_1", "utf-8"

    it "should have method #ff_coffee", ->
      expect(b).to.respondTo("ff_coffee")
      expect(b.ff_coffee).to.be.a("function")

    it "should compile coffee js code", (done) ->
      b.ff_coffee "#{FIXTURES_DIR}/coffee-code-1.coffee", OUTPUT_PATH, {bare: yes}, (err) ->
        expect(err).to.be.null
        str = fs.readFileSync(OUTPUT_PATH, "utf-8")
        fs.unlinkSync(OUTPUT_PATH)
        f = Function(str)
        expect(f()).to.equal(COFFEE_RESULT_1)
        done()


  describe "#ff_stylus", ->

    STYLUS_RESULT_1 = fs.readFileSync "#{FIXTURES_DIR}/STYLUS_RESULT_1", "utf-8"

    it "should have method #ff_stylus", ->
      expect(b).to.respondTo("ff_stylus")
      expect(b.ff_stylus).to.be.a("function")

    it "should compile stylus code", (done) ->
      b.ff_stylus "#{FIXTURES_DIR}/stylus-code-1.styl", OUTPUT_PATH, {compress: yes}, (err) ->
        expect(err).to.be.null
        str = fs.readFileSync(OUTPUT_PATH, "utf-8")
        fs.unlinkSync(OUTPUT_PATH)
        expect(str).to.have.string(STYLUS_RESULT_1)
        done()


  describe "#ff_mustache", ->

    MUSTACHE_LOCALS_1 = 
      world: "<b>world</b>"
      hash: [
        {item: "item1"}
        {item: "item2"}
        {item: "item3"}
      ]
    MUSTACHE_PARTIALS_1 = part: "<p>I'm partial!</p>"
    MUSTACHE_RESULT_1   = fs.readFileSync "#{FIXTURES_DIR}/MUSTACHE_RESULT_1", "utf-8"
    MUSTACHE_RESULT_2   = fs.readFileSync "#{FIXTURES_DIR}/MUSTACHE_RESULT_2", "utf-8"

    it "should have method #ff_mustache", ->
      expect(b).to.respondTo("ff_mustache")
      expect(b.ff_mustache).to.be.a("function")

    it "should compile mustache template code", (done) ->
      b.ff_mustache "#{FIXTURES_DIR}/mustache-code-1.mu", OUTPUT_PATH, 
      locals: MUSTACHE_LOCALS_1
      partials: MUSTACHE_PARTIALS_1
      , (err) ->
        expect(err).to.be.null
        str = fs.readFileSync(OUTPUT_PATH, "utf-8")
        fs.unlinkSync(OUTPUT_PATH)
        expect(str).to.have.string(MUSTACHE_RESULT_1)
        done()

    it "should compile mustache template to js code", (done) ->
      Template = require("hogan.js").Template
      b.ff_mustache "#{FIXTURES_DIR}/mustache-code-1.mu", OUTPUT_PATH, asString: yes, (err) ->
        expect(err).to.be.null
        str = fs.readFileSync(OUTPUT_PATH, "utf-8")
        fs.unlinkSync(OUTPUT_PATH)
        expect(str).to.have.string(MUSTACHE_RESULT_2)
        done()


  describe "#ff_coffeekup", ->

    COFFEEKUP_RESULT_1 = fs.readFileSync "#{FIXTURES_DIR}/COFFEEKUP_RESULT_1", "utf-8"

    it "should have method #ff_coffeekup", ->
      expect(b).to.respondTo("ff_coffeekup")
      expect(b.ff_coffeekup).to.be.a("function")

    it "should compile coffekup template", (done) ->
      Template = require("hogan.js").Template
      b.ff_coffeekup "#{FIXTURES_DIR}/coffeekup-code-1.ck", OUTPUT_PATH, {}, (err) ->
        expect(err).to.be.null
        str = fs.readFileSync(OUTPUT_PATH, "utf-8")
        fs.unlinkSync(OUTPUT_PATH)
        expect(str).to.have.string(COFFEEKUP_RESULT_1)
        done()


  describe "#ff_merge", ->

    MERGE_RESULT_1 = fs.readFileSync "#{FIXTURES_DIR}/MERGE_RESULT_1", "utf-8"

    it "should have method #ss_coffee", ->
      expect(b).to.respondTo("ff_merge")
      expect(b.ff_merge).to.be.a("function")

    it "should merge javascript files", (done) ->
      b.ff_merge ["#{FIXTURES_DIR}/merge-code-1.js", "#{FIXTURES_DIR}/merge-code-2.js"], OUTPUT_PATH, {}, (err) ->
        expect(err).to.be.null
        str = fs.readFileSync(OUTPUT_PATH, "utf-8")
        fs.unlinkSync(OUTPUT_PATH)
        expect(str).to.have.string(MERGE_RESULT_1)
        done()


  describe "#ff_js", ->

    JS_RESULT_1 = fs.readFileSync "#{FIXTURES_DIR}/JS_RESULT_1", "utf-8"
    JS_RESULT_2 = fs.readFileSync "#{FIXTURES_DIR}/JS_RESULT_2", "utf-8"

    it "should have method #ff_js", ->
      expect(b).to.respondTo("ff_js")
      expect(b.ff_js).to.be.a("function")

    it "should compile javascript code", (done) ->
      b.ff_js "#{FIXTURES_DIR}/js-code-1.js", OUTPUT_PATH, {}, (err) ->
        expect(err).to.be.null
        str = fs.readFileSync(OUTPUT_PATH, "utf-8")
        fs.unlinkSync(OUTPUT_PATH)
        expect(str).to.have.string(JS_RESULT_1)
        done()

    it "should compile and transform javascript code", (done) ->
      b.ff_js "#{FIXTURES_DIR}/js-code-1.js", OUTPUT_PATH, 
        transform: [b.TRANSFORM_COFFEESCRIPT_REPLACER, b.TRANSFORM_NAMESPACE_WRAPPER]
        namespace: "test"
        , (err) ->
          expect(err).to.be.null
          str = fs.readFileSync(OUTPUT_PATH, "utf-8")
          fs.unlinkSync(OUTPUT_PATH)
          expect(str).to.have.string(JS_RESULT_2)
          done()


  describe "#ff_copy", ->

    Redis = require "redis"

    COPY_FILE_1 = "#{FIXTURES_DIR}/JS_RESULT_2"
    COPY_RESULT_1 = fs.readFileSync COPY_FILE_1, "utf-8"

    OUTPUT_PATH_2 = "dbfs://main/copytest.js"

    REDIS_DB_INDEX = global.REDIS_DB_INDEX or 0


    it "should have method #ff_copy", ->
      expect(b).to.respondTo("ff_copy")
      expect(b.ff_copy).to.be.a("function")

    it "should copy file", (done) ->
      b.ff_copy COPY_FILE_1, OUTPUT_PATH, {}, (err) ->
        expect(err).to.be.null
        str = fs.readFileSync(OUTPUT_PATH, "utf-8")
        fs.unlinkSync(OUTPUT_PATH)
        expect(str).to.equal(COPY_RESULT_1)
        done()

    it "should copy file to dbfs", (done) ->
      b.initDBFS()
      b.ff_copy COPY_FILE_1, OUTPUT_PATH_2, {}, (err) ->
        b.freeDBFS()
        expect(err).to.be.null
        redis = Redis.createClient()
        redis.select(REDIS_DB_INDEX)
        redis.get OUTPUT_PATH_2, (err, str) -> 
          expect(err).to.be.null
          expect(str).to.equal(COPY_RESULT_1)
          redis.del OUTPUT_PATH_2, (err, str) ->
            redis.end()
            done()

  describe "#cake", ->

    it "should have method #cake", ->
      expect(b).to.respondTo("cake")
      expect(b.ff_copy).to.be.a("function")

    it "should exec Cakefile sync", ->
      exp = b.cake("#{FIXTURES_DIR}/cake-test")
      expect(exp).to.have.ownProperty("build")
      str = exp.build(who: "Cakefile")
      expect(str).to.equal("Cakefile successfully loaded!")

  describe "#mkdirp", ->

    it "should have method #mkdirp", ->
      expect(b).to.respondTo("mkdirp")
      expect(b.mkdirp).to.be.a("function")

    it "should create dir sync", ->
      b.mkdirp("#{__dirname}/temp/mkdirp/sync")
      exists = fs.existsSync("#{__dirname}/temp/mkdirp/sync")
      expect(exists).to.be.true

    it "should create dir async", (done) ->
      b.mkdirp "#{__dirname}/temp/mkdirp/async", (err) ->
        expect(err).to.be.null
        exists = fs.existsSync("#{__dirname}/temp/mkdirp/sync")
        expect(exists).to.be.true
        done()

    after (done) ->
      exec = require("child_process").exec
      exec("rm -rf temp", cwd: __dirname, done)

  describe "#resolve_module_dir", ->

    it "should have method #resolve_module_dir", ->
      expect(b).to.respondTo("resolve_module_dir")
      expect(b.resolve_module_dir).to.be.a("function")

    it "should resove module path", ->
      path = b.resolve_module_dir("mocha")
      truepath = fs.realpathSync(__dirname + "/../node_modules/mocha")
      expect(path).to.be.equal(truepath)
      
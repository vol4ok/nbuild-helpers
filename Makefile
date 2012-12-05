TESTS = ./test/*.coffee
REPORTER = spec

all: builder

builder: $(SRC) $(SUPPORT)
	@mkdir -p ./lib/ast
	@./node_modules/.bin/coffee -b -c -o ./lib ./src/coffeekup.coffee
	@./node_modules/.bin/coffee -b -c -o ./lib ./src/builder.coffee
	@./node_modules/.bin/coffee -b -c -o ./lib/ast ./src/ast/ast-transformers.coffee 
	@./node_modules/.bin/coffee -b -c -o ./lib/ast ./src/ast/ast-walker.coffee

clean:
	@rm -rf ./lib

test:
	@NODE_ENV=test ./node_modules/.bin/mocha \
		--compilers coffee:coffee-script \
		--reporter $(REPORTER) \
		--timeout 200 \
		--growl \
		$(TESTS)

.PHONY: test
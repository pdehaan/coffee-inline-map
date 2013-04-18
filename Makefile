M4 := m4
COFFEE := node_modules/.bin/coffee
MOCHA := node_modules/.bin/mocha
OPTS :=

out := lib
js_temp := $(patsubst %.coffee,$(out)/%.js,$(wildcard *.coffee))

.PHONY: clobber clean compile

all: test

node_modules: package.json
	npm install
	touch $@

test: compile
	$(MOCHA) --compilers coffee:coffee-script -u tdd test $(OPTS)

lib/%.js: %.coffee
	$(COFFEE) -o $(out) -c $<

README.html: README.md
	pandoc $< -o $@

README.md: README.m4.md
	cd test/data/src ; \
		$(MAKE) clean; \
		$(M4) ../../../$< > ../../../$@

compile: node_modules $(js_temp) README.md

clean:

clobber: clean
	rm -rf node_modules

# Debug. Use 'gmake p-obj' to print $(obj) variable.
p-%:
	@echo $* = $($*)
	@echo $*\'s origin is $(origin $*)

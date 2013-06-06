# coffee-inline-map

Compile CoffeeScript files with inline source maps.

## Features

* Error reporting similar to the original CoffeeScript compiler.
* `.litcoffee` support.

## Example

```
$ cat a.coffee
module.exports = (something) -> console.log something

$ coffee-inline-map a.coffee | fold -w72
(function() {
  module.exports = function(something) {
    return console.log(something);
  };

}).call(this);

//@ sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaW
xlIjoiYS5jb2ZmZWUiLCJzb3VyY2VSb290IjoiIiwic291cmNlcyI6WyJhLmNvZmZlZSJdLC
JuYW1lcyI6W10sIm1hcHBpbmdzIjoiQUFBQTtDQUFBLENBQUEsQ0FBaUIsR0FBWCxDQUFOLE
VBQWtCO0NBQXNCLEVBQVIsSUFBTyxFQUFQLEVBQUE7Q0FBaEMsRUFBaUI7Q0FBakIiLCJzb3
VyY2VzQ29udGVudCI6WyJtb2R1bGUuZXhwb3J0cyA9IChzb21ldGhpbmcpIC0+IGNvbnNvbG
UubG9nIHNvbWV0aGluZ1xuIl19

$ coffee-inline-map -h
Usage: coffee-inline-map [options] [file.coffee]

Available options:
  -h, --help            output usage information & exit
  -V, --version         output the version number & exit
  -o, --output [FILE]   write result to a FILE instead of stdout
  -l, --literate        treat stdin as literate style coffee-script
      --no-map          don't include inline source map (why?)

```

## Installation

    # npm install -g coffee-inline-map

## Compilation

    $ make compile

## browserify & make-commonjs-depend

To verify the text below you'll need to clone this repo, run 'make
compile', install
[make-commonjs-depend](https://github.com/gromnitsky/make-commonjs-depend)
& browserify.

Look into repo's `test/data` directory. Ignore `*.should` files. I'll wait.

Then

```
$ cd src
$ ls *coffee
a.coffee
b.litcoffee
main.coffee

```

Here `main.coffee` depends on `a.coffee` & `b.litcoffee`. For out site
we need just 1 `public/bundle.js` file which will include the result form the
compilations of our all CoffeeScript files.

We want to rebuild `public/bundle.js` only & only on .coffee files
change. That's obviously a job for make.

```
$ cat Makefile
COFFEE_COMPILER := ../../../bin/coffee-inline-map

out := ../public
js_temp := \
	$(patsubst %.coffee,%.js,$(wildcard *.coffee)) \
	$(patsubst %.litcoffee,%.js,$(wildcard *.litcoffee))
bundle := $(out)/bundle.js

.PHONY: depend compile compile-js clean

all: compile

%.js: %.coffee
	$(COFFEE_COMPILER) $< -o $@

%.js: %.litcoffee
	$(COFFEE_COMPILER) $< -o $@

depend: compile-js
	make-commonjs-depend *js -o js.mk

-include js.mk

compile-js: $(js_temp)
compile: compile-js $(bundle)

$(bundle): main.js
	@mkdir -p $(out)
	browserify -d $< -o $@

clean:
	rm -f js.mk $(js_temp) $(bundle)

```

To create a dependency tree, we run

```
$ make depend
../../../bin/coffee-inline-map a.coffee -o a.js
../../../bin/coffee-inline-map main.coffee -o main.js
../../../bin/coffee-inline-map b.litcoffee -o b.js
make-commonjs-depend *js -o js.mk

```

```
$ cat js.mk
a.js:
b.js:
main.js: \
  a.js \
  b.js

```

It's unfortunate that make-commonjs-depend supports only
javascript. That's why before running it, make needs to compile all
coffescript files.

Then compile the bundle

```
$ make compile
../../../bin/coffee-inline-map main.coffee -o main.js
browserify -d main.js -o ../public/bundle.js

```

As a little homework, try to guess why `main.js` was recompiled here,
when at first glance it should rather not.

Run again

```
$ make compile
make[1]: Nothing to be done for `compile'.

```

Notice that the nothing was recompiled for the 2nd time. That's our goal!

```
$ touch a.coffee
$ make compile
../../../bin/coffee-inline-map a.coffee -o a.js
../../../bin/coffee-inline-map main.coffee -o main.js
browserify -d main.js -o ../public/bundle.js

```

Yay! Then open `public/index.html` in Chrome and switch to the console
view. (Make sure to turn on 'Enable source maps' in Developer Tool's
settings.)

## Jeez mate, why are you doing this rigmarole?

Every dependency & every file should be compiled/processed only once.

This seems meaningless for a bunch of small .coffee files but becomes
very useful for large projects with several complex browserify output
targets.

## Why not just use coffeeify plugin for browserify?

1. browserify can't (& shouldn't) check what has changed in our source
   files to decide whether it's time to recompile.
2. Error reporting.

## Why are you using outdated make instead of cake, jake or grunt? It's not 1977 anymore!

facepalm.jpg

Dude. <br/>
Just take a walk for 10 minutes & no one will hurt.

## BUGS

* Reading from stdin doesn't work in Windows.

## NEWS

### 0.2.0

* Update for CoffeeScript 1.6.3.
* Recognize `.coffee.md` extension.
* `-l` CLO.

### 0.1.0

* Add reading from stdin.
* Fix an unheplful crash for EPIPE error.

## License

MIT.

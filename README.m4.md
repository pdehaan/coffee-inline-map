changequote([,])dnl
# coffee-inline-map

Compile CoffeeScript files with inline source maps.

    $ coffee-inline-map -h
```
syscmd([../../../bin/coffee-inline-map -h])
```

## Features

* Error reporting similar to the original CoffeeScript compiler.
* `.litcoffee` support.

## Installation

    # npm install -g coffee-inline-map

## Compilation

	$ make compile

## browserify & make-commonjs-depend

To verify the text below you'll need to clone this repo, run 'make
compile', install
[[make-commonjs-depend]](https://github.com/gromnitsky/make-commonjs-depend)
and browserify.

Look into repo's `test/data` directory. I'll wait.

Then

    $ cd src
    $ ls *coffee
```
syscmd([ls *coffee])
```

Here `main.coffee` depends on `a.coffee` & `b.litcoffee`. For out site
we need just 1 `public/bundle.js` file which will include the result form the
compilations of our all CoffeeScript files.

We want to rebuild `public/bundle.js` only & only on .coffee files
change. That's obviously a job for make.

    $ cat Makefile
```
include([Makefile])
```

To create a dependency tree, we run

    $ make depend
```
syscmd([make depend | egrep -v '(Entering|Leaving) directory'])
```

    $ cat js.mk
```
include([js.mk])
```

It's unfortunate that make-commonjs-depend supports only
javascript. That's why before running it, make needs to compile all
coffescript files.

Then compile the bundle

    $ make compile
```
syscmd([make compile | egrep -v '(Entering|Leaving) directory'])
```

As a little homework, try to guess why `main.js` was recompiled here,
when at first glance it should rather not.

Run again

    $ make compile
```
syscmd([make compile | egrep -v '(Entering|Leaving) directory'])
```

Notice that the nothing was recompiled for the 2nd time. That's our goal!

    $ touch a.coffee
    $ make compile
```
syscmd([touch a.coffee; make compile | egrep -v '(Entering|Leaving) directory'])
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

## Why are you using outdated make instead of cake or jake? It's not 1977 anymore!

facepalm.jpg

Dude. <br/>
Just take a walk for 10 minutes & no one will hurt.

## License

MIT.
# This project is no longer active

You may want to check out this [alternative approach](https://github.com/chicken-mobile/android-chicken)
to build Chicken Scheme projects for Android. It utilizes Chicken Scheme's to cross-compile, and the NDK's ability to
produce a stand-alone cross-compiler for a particular platform.

This project takes on a different approach: it produces NDK makefiles. It is currently not maintained, but is left here
for reference.

# chicken-mobile

A lightweight script to aid building chicken eggs and modules. In a very early development stage! 
See the `android` directory for a set of Chicken NDK modules that you can
[import](http://www.kandroid.org/ndk/docs/IMPORT-MODULE.html) into your project.

## One way to “install”

```bash
$ git clone <this repo>
$ ln -s $PWD/<this repo>/chicken-mobile.scm ~/bin/chicken-mobile
```

## Trying it out

```bash
$ ls -l ~/bin
lrwxrwxrwx 1 klm users   45 Nov 22 13:37 chicken-mobile -> ~/projects/chicken-mobile/chicken-mobile.scm
$ mkdir /tmp/chicken-mobile-test/ -p
$ cd /tmp/chicken-mobile-test/
$ chicken-mobile
$ find .
```

## Todo

* Make Chicken.mk work with the target build-dir
* Don't hardcode included modules! (duh)
 * Read them from a nice project.scm instead
* Allow building non-module compilation units (non-eggs in current-project)
* Add plugin-features to allow compiling non-trivial modules, like chickmunk and cocoscheme

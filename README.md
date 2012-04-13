  [Chicken Scheme]: http://call-cc.org
  [Android NDK]: http://developer.android.com/sdk/ndk/index.html

# [Chicken Scheme] on Android

This template of Makefiles should let you:

* Build [Chicken Scheme] as a dynamic library using just ndk-build (`libchicken.so`)
* Build shared libs from Scheme sources files (`libtest.so`) that can be used with `(load "libtest.so")`
* Build executables from Scheme source files


You will need:

* The [Android NDK] (I'm on `android-ndk-r7`)
* [Chicken Scheme] (I'm on 4.7.0.4) 

You'll have to build Chicken so it's ready with its C source files in place. This is your `CHICKEN_HOME` directory (where e.g. runtime.c and chicken.h are).

## Building 

For now, you'll have to modify `CHICKEN_HOME` in `jni/Android.mk` to point to your Chicken sources.

Then, you'll have to build the test module:

    $ csc -t -s jni/test.scm

This should produce `test.c`. Now try `ndk-build` from the project root. You should get `libchicken.so` and `csi` under `libs/`. Building Chicken takes a long time! Now you can push the files under `./libs` to a writeable place on your phone and start `csi`:

    $ adb push libs/armeabi/ /cache/
    $ adb shell
    # cd /cache/
    # LD_LIBRARY_PATH=. ./csi

## Todos

We're early in development! Stay tuned for a more convenient tool:

* Generate project-specific makefiles
 * CHICKEN_HOME can automatically be handled
* Include makefiles for Chicken Egg dependencies



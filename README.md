  [Chicken Scheme]: http://call-cc.org
  [Android NDK]: http://developer.android.com/sdk/ndk/index.html
  [Changing LD_LIBRARY_PATH]: http://groups.google.com/group/android-ndk/browse_thread/thread/da2cb8cdeca854a5/77fb7dd33bb376f7

# [Chicken Scheme] on Android

This is a set of makefiles for the NDK that:

* Builds [Chicken Scheme] as a dynamic library using just `ndk-build`
* Builds `csi` for debugging/testing
* Helps building libs from Scheme sources files that can be included in your app
* Helps with runtime loading of compiled libraries, e.g. `(require 'mylib)`

Requirements:

* [Chicken Scheme] \(I'm on 4.7.0.4) 
* [Android NDK] \(I'm on `android-ndk-r7`)

## Building 

You'll have to build Chicken so it's ready with its C source files in place. If you have already built it for your desktop, this should suffice. 

Provide `CHICKEN_HOME`, where `runtime.c`, `chicken.h` and `eval.scm` etc live and start the NDK-build toolchain:

    $ CHICKEN_HOME=/your/chicken-core/folder/ ndk-build # -j 4 for the brave

This takes a long time! When done, you should see `libs/armeabi/libchicken.so` and `libs/armeabi/csi`. 
To run `csi` on your device/emulator, push the binaries to a writeable place and launch:

    $ adb push libs/armeabi/ /cache/
    $ adb shell
    # cd /cache/
    # LD_LIBRARY_PATH=. ./csi

## Using in another project

1. Compile your Scheme sources to C with `csc -t`  
   *Note*: you don't need an Android version of `csc` since it will only compile to C.
1. Import the `chicken` module with 
   `$(call import-add-path,$(ANDROID_CHICKEN_HOME)/modules-prebuilt)` and
   `$(call import-module,chicken)`
1. Add this `chicken` module as a dependency of your project: `LOCAL_SHARED_LIBRARIES += chicken`

By using the prebuilt version, you don't have to recompile chicken for every Chicken Android project. 
There's a small sample project in the `samples` directory that can give some guidelines. 

    $ cd samples/chicken-android-jni/
    $ ndk-build
    $ android update project -n SampleJni -p . -t android-10
    $ ant debug
    $ adb install -r bin/SampleJni-debug.apk

This should build the sameple app and install it on your device or emulator.

## Notes / troubleshoot

* When linking dynamically at the build-stage, 
like chicken is linked against the jni-sample, you need to manually load the dynamically load the dependency
first with `System.loadLibrary(...)`. See [Changing LD_LIBRARY_PATH].

* Don't forget to `CHICKEN_run(C_toplevel)` somewhere before your first chicken-call.

* Don't forget to `(return-to-host)` or your app will exit after `CHICKEN_run`.

## Todos

We're early in development! Stay tuned for a more convenient tool:

* Generate makefiles/modules based on Egg desctiptions
* Include makefiles for Chicken Egg dependencies
* Abort build if `csc` fails

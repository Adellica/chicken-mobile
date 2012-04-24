  [Chicken Scheme]: http://call-cc.org
  [Android NDK]: http://developer.android.com/sdk/ndk/index.html

# [Chicken Scheme] on Android

This template of Makefiles that:

* Builds [Chicken Scheme] as a dynamic library using just ndk-build (`libchicken.so`)
* Builds `csi` for debugging/testing
* Helps building libs from Scheme sources files that can be loaded at runtime `(require 'mylib)`

Requirements:

* [Chicken Scheme] \(I'm on 4.7.0.4) 
* [Android NDK] \(I'm on `android-ndk-r7`)

## Building 

You'll have to build Chicken so it's ready with its C source files in place. If you have already built it for your desktop, this should suffice. 

Provide `CHICKEN_HOME`, where `runtime.c`, `chicken.h` and `eval.scm` etc live and start the NDK-build toolchain:

    $ CHICKEN_HOME=/your/chicken-core/folder/ ndk-build

This takes a long time! When done, you should see `libs/armeabi/libchicken.so` and `libs/armeabi/csi`. 
To run `csi` on your device/emulator, push the binaries to a writeable place and launch:

    $ adb push libs/armeabi/ /cache/
    $ adb shell
    # cd /cache/
    # LD_LIBRARY_PATH=. ./csi

## Using in another project

Compile your Scheme sources to C with `csc -t` and use the `chicken` module provided by this project. 
Note that you don't need an Android version of `csc` since it will only compile to C.
By using the prebuilt version, you don't have to recompile chicken for every Chicken Android project. Here's
an example of an `Android.mk`:

    LOCAL_PATH := $(call my-dir)
    include $(CLEAR_VARS)
    LOCAL_MODULE := jni-sample
    $(shell csc -t jni/jni-sample.scm)
    LOCAL_SRC_FILES := jni-sample.c
    LOCAL_SHARED_LIBRARIES := chicken
    include $(BUILD_SHARED_LIBRARY)
    $(call import-add-path,$(CHICKEN_ANDROID_HOME)/modules-prebuilt)
    $(call import-module,chicken)


## Todos

We're early in development! Stay tuned for a more convenient tool:

* Generate makefiles/modules based on Egg desctiptions
* Include makefiles for Chicken Egg dependencies
* Abort build if `csc` fails

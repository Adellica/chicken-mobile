
  [Chicken Scheme]: http://call-cc.org
  [Android NDK]: http://developer.android.com/sdk/ndk/index.html

# [Chicken Scheme] on Android

This template of Makefiles should let you:

* Build [Chicken Scheme] as a dynamic library using just ndk-build (`libchicken.so`)
* Build shared libs from Scheme sources files (`libtest.so`) that can be used with `(load "libtest.so")`
* Build executables from Scheme source files

Requirements:

* [Chicken Scheme] \(I'm on 4.7.0.4) 
* [Android NDK] \(I'm on `android-ndk-r7`)

## Building 

You'll have to build Chicken so it's ready with its C source files in place. If you have already built it for your desktop, this will suffice. 

Provide `CHICKEN_HOME`, where `runtime.c`, `chicken.h` and `eval.scm` etc live and start the NDK-build toolchain:

    $ CHICKEN_HOME=/your/chicken-core/folder/ ndk-build

This takes a long time! When done, you should see two files under `./libs`:

* armeabi/libchicken.so
* armeabi/csi

To run `csi` on your device/emulator, push the binaries to a writeable place on your phone and launch:

    $ adb push libs/armeabi/ /cache/
    $ adb shell
    # cd /cache/
    # LD_LIBRARY_PATH=. ./csi

## Using in another project

This is a TODO, but here are some hints:

    include $(CLEAR_VARS)
    LOCAL_MODULE := chicken
    LOCAL_PATH := $(ANDROID_CHICKEN_HOME)
    LOCAL_SRC_FILES := libs/armeabi/libchicken.so
    LOCAL_EXPORT_C_INCLUDES := $(CHICKEN_HOME)
    LOCAL_EXPORT_CFLAGS := -DC_INSTALL_PREFIX=\"/cache/\"
    include $(PREBUILT_SHARED_LIBRARY)


## Todos

We're early in development! Stay tuned for a more convenient tool:

* Generate project-specific makefiles
 * CHICKEN_HOME can automatically be handled
* Include makefiles for Chicken Egg dependencies

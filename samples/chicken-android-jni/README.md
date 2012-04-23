
# Simple Chicken Android JNI sample

This is an example that may illustrate how the toolchains could be set
up to build an Android app that uses libchicken.so.


## Building

    ndk-build
    ant clean debug
    adb install -r bin/ChickenJniSample-debug.apk

Note that when you update your native libraries, it seems you must do
an `$ ant clean` for the new libs to show up in your `.apk`.

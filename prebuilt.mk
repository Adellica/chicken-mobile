
# Include this file into your Android projects
# wich the chicken dependency, like this:
# LOCAL_SHARED_LIBRARIES += chicken

# get dir of this file
CHICKEN_PREBUILT_HOME := $(dir $(lastword $(MAKEFILE_LIST)))
include $(CHICKEN_PREBUILT_HOME)/.chicken-home.mk

include $(CLEAR_VARS)
LOCAL_MODULE := chicken
LOCAL_PATH := $(CHICKEN_PREBUILT_HOME)
LOCAL_SRC_FILES := libs/armeabi/libchicken.so
include $(CHICKEN_PREBUILT_HOME)/chicken-exports.mk
include $(PREBUILT_SHARED_LIBRARY)

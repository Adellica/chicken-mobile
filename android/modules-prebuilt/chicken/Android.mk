
# Include this file into your Android projects
# wich the chicken dependency, like this:
# LOCAL_SHARED_LIBRARIES += chicken

# get dir of this file
LOCAL_HOME := $(dir $(lastword $(MAKEFILE_LIST)))/../..
include $(LOCAL_HOME)/.chicken-home.mk

include $(CLEAR_VARS)
LOCAL_MODULE := chicken
LOCAL_PATH := $(LOCAL_HOME)
LOCAL_SRC_FILES := libs/armeabi/libchicken.so
include $(LOCAL_HOME)/chicken-exports.mk
include $(PREBUILT_SHARED_LIBRARY)

# include definitions of scheme.import, chicken.import etc etc
include $(LOCAL_HOME)/chicken-imports.mk

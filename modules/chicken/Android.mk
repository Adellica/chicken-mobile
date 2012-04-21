
LOCAL_HOME := $(dir $(lastword $(MAKEFILE_LIST)))/../../

include $(LOCAL_HOME)/.chicken-home.mk
include $(LOCAL_HOME)/chicken.mk
include $(LOCAL_HOME)/csi.mk


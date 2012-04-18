
LOCAL_HOME := $(call my-dir)
ifeq "" "$(CHICKEN_HOME)"
 $(error Missing CHICKEN_HOME variable. Please try\
CHICKEN_HOME=/path/to/your/chicken ndk-build. \
In CHICKEN_HOME, you should find runtime.c, eval.scm, chicken.h etc)
endif

include chicken.mk
include csi.mk



LOCAL_HOME := $(call my-dir)
ifeq "" "$(CHICKEN_HOME)"
 $(error Missing CHICKEN_HOME variable. Please try\
CHICKEN_HOME=/path/to/your/chicken ndk-build. \
In CHICKEN_HOME, you should find runtime.c, eval.scm, chicken.h etc)
endif

# store CHICKEN_HOME so prebuilt.mk can use it
$(shell echo CHICKEN_HOME := $(CHICKEN_HOME) > .chicken-home.mk)

include chicken.mk
include csi.mk


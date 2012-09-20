
# we must make path of current makefile absolute
# because of the special case of LOCAL_PATH being /
LOCAL_HOME := $(dir $(lastword $(MAKEFILE_LIST)))

include $(CLEAR_VARS)

# LOCAL_SRC_FILES cannot contain absolute pathnames
# (LOCAL_PATH is unconditionally prepended)
LOCAL_PATH := /

LOCAL_C_INCLUDES := $(CHICKEN_HOME)
LOCAL_CFLAGS := -DHAVE_DLFCN_H -DPIC -DC_ENABLE_PTABLES -DC_BUILDING_LIBCHICKEN -DC_SHARED -DC_INSTALL_LIB_NAME=\"chicken\"
include $(LOCAL_HOME)/chicken-exports.mk

// TODO: cleanup this part of build-process
$(shell csc -t jni/find-extension.scm)

LOCAL_MODULE    := chicken
LOCAL_SRC_FILES := $(CHICKEN_HOME)/runtime.c \
	$(CHICKEN_HOME)/library.c \
	$(CHICKEN_HOME)/ports.c \
	$(CHICKEN_HOME)/eval.c \
	$(CHICKEN_HOME)/expand.c \
	$(CHICKEN_HOME)/tcp.c \
	$(CHICKEN_HOME)/extras.c \
	$(CHICKEN_HOME)/scheduler.c \
	$(CHICKEN_HOME)/data-structures.c \
	$(CHICKEN_HOME)/chicken-syntax.c \
	$(CHICKEN_HOME)/srfi-1.c \
	$(CHICKEN_HOME)/srfi-4.c \
	$(CHICKEN_HOME)/srfi-18.c \
	$(CHICKEN_HOME)/lolevel.c $(CHICKEN_HOME)/srfi-69.c \
	$(CHICKEN_HOME)/irregex.c \
	$(CHICKEN_HOME)/files.c \
	$(CHICKEN_HOME)/srfi-13.c $(CHICKEN_HOME)/srfi-14.c \
	$(CHICKEN_HOME)/build-version.c \
	$(CHICKEN_HOME)/modules.c \
	$(shell pwd)/$(LOCAL_HOME)/jni/find-extension.c

include $(BUILD_SHARED_LIBRARY)

include $(LOCAL_HOME)/chicken-imports.mk

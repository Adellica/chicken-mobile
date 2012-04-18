include $(CLEAR_VARS)

LOCAL_PATH := $(CHICKEN_HOME)
LOCAL_CFLAGS := -DHAVE_DLFCN_H -DPIC -DC_ENABLE_PTABLES -DC_BUILDING_LIBCHICKEN
include chicken-exports.mk

LOCAL_MODULE    := chicken
LOCAL_SRC_FILES := runtime.c \
	library.c \
	ports.c \
	eval.c \
	expand.c \
	tcp.c \
	extras.c \
	scheduler.c \
	data-structures.c \
	chicken-syntax.c \
	srfi-1.c \
	srfi-18.c \
	build-version.c \
	modules.c

include $(BUILD_SHARED_LIBRARY)

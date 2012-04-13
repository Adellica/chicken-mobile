include $(CLEAR_VARS)

LOCAL_PATH := $(CHICKEN_HOME)
# export the include path (for chicken.h) and preprocessor vars.
# all dependencies of chicken will have the exports applied
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)
LOCAL_EXPORT_CFLAGS := -DC_INSTALL_PREFIX=\"/cache/\"
LOCAL_CFLAGS := -DHAVE_DLFCN_H -DPIC -DC_ENABLE_PTABLES -DC_BUILDING_LIBCHICKEN

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

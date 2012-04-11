
MY_LOCAL_PATH := $(call my-dir)

#CHICKEN_HOME := unset
# I can't get this to work:
#$(if $(wildcard "./jni/local.mk"),include "./jni/local.mk") 




include ./jni/local.mk


LOCAL_PATH:= $(CHICKEN_HOME)


include $(CLEAR_VARS)
 
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




include $(CLEAR_VARS)
LOCAL_MODULE := test
LOCAL_PATH := $(MY_LOCAL_PATH)
LOCAL_SRC_FILES := test.c
#LOCAL_LDLIBS := -lchicken -L$(MY_LOCAL_PATH)/../libs/armeabi
LOCAL_SHARED_LIBRARIES := chicken
include $(BUILD_EXECUTABLE)


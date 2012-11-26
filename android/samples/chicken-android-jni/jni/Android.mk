

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := jni-sample
$(shell csc -t jni/jni-sample.scm)
LOCAL_SRC_FILES := jni-sample.c
LOCAL_SHARED_LIBRARIES := chicken
include $(BUILD_SHARED_LIBRARY)

$(call import-add-path,../../modules-prebuilt)
$(call import-module,chicken)

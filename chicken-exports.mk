
# these are used by csi and prebuilt
# all dependencies (LOCAL_SHARED_LIBRARIES) of chicken 
# will have these exports applied by the NDK

# export the include path (for chicken.h) 

LOCAL_EXPORT_C_INCLUDES := $(CHICKEN_HOME)

# export preprocessor vars 
# (this should never be used by chicken runtime,
# but it seems to be required)
LOCAL_EXPORT_CFLAGS := -DC_INSTALL_PREFIX=\"/non-existing-path/\"

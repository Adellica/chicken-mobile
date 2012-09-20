
# build all import shared libs
# these are loaded by libchicken
# when requiring these built-ins
# at runtime 

define build-shared-import
	include $(CLEAR_VARS)
	LOCAL_MODULE := $1.import
	LOCAL_PATH := $(CHICKEN_HOME)
	LOCAL_SRC_FILES := $1.import.c
	LOCAL_SHARED_LIBRARIES := chicken
	include $(BUILD_SHARED_LIBRARY)
endef

$(eval $(call build-shared-import,chicken))
$(eval $(call build-shared-import,srfi-18))
$(eval $(call build-shared-import,tcp))
$(eval $(call build-shared-import,data-structures))
$(eval $(call build-shared-import,utils))
$(eval $(call build-shared-import,irregex))
$(eval $(call build-shared-import,extras))
$(eval $(call build-shared-import,srfi-13))
$(eval $(call build-shared-import,srfi-69))
$(eval $(call build-shared-import,srfi-4))
$(eval $(call build-shared-import,foreign))
$(eval $(call build-shared-import,ports))
$(eval $(call build-shared-import,srfi-1))
$(eval $(call build-shared-import,files))
$(eval $(call build-shared-import,srfi-14))
#$(eval $(call build-shared-import,scheme))
$(eval $(call build-shared-import,lolevel))
#$(eval $(call build-shared-import,posix))
#$(eval $(call build-shared-import,csi))
#$(eval $(call build-shared-import,setup-download))
#$(eval $(call build-shared-import,setup-api))


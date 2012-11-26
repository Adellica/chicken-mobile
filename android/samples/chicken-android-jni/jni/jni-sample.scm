
#>
#include <jni.h>
// we need to initialize chicken!
JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM *vm, void *reserved)
{
 CHICKEN_run(C_toplevel);
 return JNI_VERSION_1_6;
}
<#


(define-external
  (Java_org_chickenscheme_android_samples_jni_SampleActivity_square
   (c-pointer JNIEnv) (c-pointer jclass) (int number)) int
   (* number number))


(return-to-host)

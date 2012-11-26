package org.chickenscheme.android.samples.jni;

import android.app.Activity;
import android.os.Bundle;
import android.widget.TextView;

public class SampleActivity extends Activity {
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);

        ((TextView)findViewById(R.id.label)).setText("`square` from jni says 101^2 = " + square(101));
    }
    
    public static native int square(int number);

    static {
    	// tricky business: chicken needs to load before jni-sample
    	// see http://groups.google.com/group/android-ndk/browse_thread/thread/da2cb8cdeca854a5/77fb7dd33bb376f7
        System.loadLibrary("chicken");
        System.loadLibrary("jni-sample");
    }
}

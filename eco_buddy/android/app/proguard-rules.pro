# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.

# Keep AR Sceneform classes
-keep class com.google.ar.sceneform.** { *; }
-keep class com.google.ar.sceneform.animation.** { *; }
-keep class com.google.ar.sceneform.assets.** { *; }
-keep class com.google.ar.sceneform.rendering.** { *; }
-keep class com.google.ar.sceneform.utilities.** { *; }

# Keep TensorFlow Lite classes
-keep class org.tensorflow.lite.** { *; }
-keep class org.tensorflow.lite.gpu.** { *; }

# Keep Google AR Core classes
-keep class com.google.ar.core.** { *; }

# Keep Flutter classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Desugar runtime classes
-keep class com.google.devtools.build.android.desugar.runtime.** { *; }

# Suppress warnings for missing classes that are platform-specific
-dontwarn com.google.ar.sceneform.**
-dontwarn org.tensorflow.lite.**
-dontwarn com.google.devtools.build.android.desugar.runtime.**

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep enum values
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}
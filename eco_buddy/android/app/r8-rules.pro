# R8 specific rules for AR Flutter Plugin and dependencies

# Keep all AR Sceneform classes
-keep class com.google.ar.sceneform.** { *; }
-keep interface com.google.ar.sceneform.** { *; }

# Keep AR Sceneform animation classes
-keep class com.google.ar.sceneform.animation.AnimationEngine { *; }
-keep class com.google.ar.sceneform.animation.AnimationLibraryLoader { *; }

# Keep AR Sceneform assets classes
-keep class com.google.ar.sceneform.assets.Loader { *; }
-keep class com.google.ar.sceneform.assets.ModelData { *; }

# Keep TensorFlow Lite GPU classes
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory$Options { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegate { *; }

# Keep Desugar runtime classes
-keep class com.google.devtools.build.android.desugar.runtime.ThrowableExtension { *; }

# Don't warn about missing platform classes
-dontwarn com.google.ar.sceneform.**
-dontwarn org.tensorflow.lite.gpu.**
-dontwarn com.google.devtools.build.android.desugar.runtime.**

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep all methods that might be called via reflection
-keepclassmembers class com.google.ar.sceneform.** {
    *;
}

# Additional rules for AR Core
-keep class com.google.ar.core.** { *; }
-dontwarn com.google.ar.core.**
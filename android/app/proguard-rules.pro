# Flutter Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.embedding.**

# Firebase Rules
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Google Sign In
-keep class com.google.android.gms.auth.api.signin.** { *; }
-keep class com.google.android.gms.common.** { *; }
-dontwarn com.google.android.gms.**

# Cloud Firestore & gRPC
-keep class io.grpc.** { *; }
-dontwarn io.grpc.**
-keep class com.google.firestore.** { *; }

# Crashlytics
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod
-keep class com.google.firebase.crashlytics.** { *; }
-dontwarn com.google.firebase.crashlytics.**

# Hive
-keep class com.github.davidmoten.** { *; }
-dontwarn com.github.davidmoten.**

# OjekHub ProGuard Rules for Release Build

# Keep Supabase Auth classes
-keep class io.supabase.** { *; }
-keep class gotrue.** { *; }
-keep class io.github.jan.supabase.** { *; }

# Keep Flutter URL handling
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep deep link handling
-keep class android.net.Uri { *; }
-keepattributes *Annotation*

# Keep URL parsing for OAuth callback
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Don't obfuscate model classes (Dio, JSON parsing)
-keep class com.google.gson.** { *; }
-keepattributes Signature
-keepattributes *Annotation*

# Keep Dio HTTP client
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-keep class retrofit2.** { *; }

# Prevent stripping of Chrome Custom Tabs
-keep class androidx.browser.** { *; }

# Suppress warnings for Google Play Core (Flutter deferred components - not used)
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

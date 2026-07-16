# Referenced by android/app/build.gradle.kts (release buildType, R8 minify + shrinkResources).
# File didn't exist before, so R8 was running on release builds with zero project-specific
# keep rules — only relying on each library's bundled consumer-rules.pro.

# Firebase (Auth / Messaging / Core) reflection-based model classes.
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Google Play Services / Google Sign-In.
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# flutter_local_notifications uses reflection to read notification icons/actions.
-keep class com.dexterous.** { *; }

# Play Core (Flutter's deferred components glue) — safe to keep, avoids R8
# "missing_rules" failures on some AGP/Play Core version combos.
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

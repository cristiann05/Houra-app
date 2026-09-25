# Reglas de ProGuard/R8 para Houra.
# Firebase, Play Core y flutter_svg necesitan mantenerse sin ofuscar en ciertos puntos.

# Firebase / Firestore / Auth / Crashlytics
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**

# Crashlytics necesita los nombres de clase originales para simbolizar los stack traces
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# Flutter embedding (por si acaso, aunque Flutter Gradle Plugin ya trae las suyas)
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Play Core: Flutter lo referencia para deferred components (no usado en Houra)
-dontwarn com.google.android.play.core.**
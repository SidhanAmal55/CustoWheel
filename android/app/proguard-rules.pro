# Keep ML Kit text recognition classes
-keep class com.google.mlkit.vision.text.** { *; }
-dontwarn com.google.mlkit.vision.text.**

# Avoid crashing for unused language models
-assumenosideeffects class com.google.mlkit.vision.text.chinese.** { *; }
-assumenosideeffects class com.google.mlkit.vision.text.korean.** { *; }
-assumenosideeffects class com.google.mlkit.vision.text.japanese.** { *; }
-assumenosideeffects class com.google.mlkit.vision.text.devanagari.** { *; }

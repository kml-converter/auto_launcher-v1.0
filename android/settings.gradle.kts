pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        val localPropertiesFile = settingsDir.resolve("local.properties")
        if (localPropertiesFile.exists()) {
            localPropertiesFile.inputStream().use { properties.load(it) }
        }
        
        System.getenv("FLUTTER_ROOT")
            ?: properties.getProperty("flutter.sdk")
            ?: throw GradleException("Flutter SDK non trovato. Imposta FLUTTER_ROOT o flutter.sdk")
    }
    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")
    
    // CORREZIONE: Dice a Gradle dove cercare i plugin Android e Kotlin
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-gradle-plugin") version "1.0.0" apply false
    id("com.android.application") version "8.1.0" apply false // Aggiornato per compatibilità
    id("org.jetbrains.kotlin.android") version "1.8.22" apply false // Aggiornato per compatibilità
}

include(":app")

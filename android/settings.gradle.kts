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
    
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-gradle-plugin") apply false
    id("com.android.application") version "8.1.0" apply false
    kotlin("android") version "1.9.22" apply false
}

include(":app")

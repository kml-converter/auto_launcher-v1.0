pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        val file = settingsDir.resolve("local.properties")
        if (file.exists()) {
            file.reader(Charsets.UTF_8).use { properties.load(it) }
        }
        val sdkPath = properties.getProperty("flutter.sdk") ?: System.getenv("FLUTTER_ROOT")
        requireNotNull(sdkPath) { "Flutter SDK not found. Define flutter.sdk in local.properties or FLUTTER_ROOT env variable." }
        sdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("com.android.application") version "8.1.0" apply false
    id("org.jetbrains.kotlin.android") version "1.8.22" apply false // Downgrade a versione stabile per bloccare i crash dei plugin
    id("dev.flutter.flutter-gradle-plugin") version "1.0.0" apply false
}

include(":app")

pluginManagement {
    val flutterSdkPath = settingsDir.parentFile.resolve(".flutter-sdk").absolutePath
    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")
}
plugins {
    id("dev.flutter.flutter-gradle-plugin") version "1.0.0" apply false
    id("com.android.application") version "8.7.0" apply false
    id("org.jetbrains.kotlin.android") version "2.0.0" apply false
}
include(":app")


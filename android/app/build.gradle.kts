import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
println("Looking for key.properties at: ${keystorePropertiesFile.absolutePath}")
println("Exists: ${keystorePropertiesFile.exists()}")

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.akhileshgulia.gta6companion"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

   signingConfigs {
    create("release") {
        println("keyAlias = ${keystoreProperties["keyAlias"]}")
        println("keyPassword = ${keystoreProperties["keyPassword"]}")
        println("storeFile = ${keystoreProperties["storeFile"]}")
        println("storePassword = ${keystoreProperties["storePassword"]}")

        keyAlias = keystoreProperties["keyAlias"] as String
        keyPassword = keystoreProperties["keyPassword"] as String
        storeFile = file(keystoreProperties["storeFile"] as String)
        storePassword = keystoreProperties["storePassword"] as String
    }
}
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.akhileshgulia.gta6companion"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }

   
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
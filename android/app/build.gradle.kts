plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "net.vielmond.ruapp"
    compileSdk = 35 // flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" //flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "net.vielmond.ruapp"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 27 // flutter.minSdkVersion
        targetSdk = 35 // flutter.targetSdkVersion
        versionCode = 1 // flutter.versionCode
        versionName = "1.0.0" // flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (project.hasProperty("MYAPP_UPLOAD_STORE_FILE")) {
                storeFile = file(project.property("MYAPP_UPLOAD_STORE_FILE").toString())
                storePassword = project.property("MYAPP_UPLOAD_STORE_PASSWORD").toString()
                keyAlias = project.property("MYAPP_UPLOAD_KEY_ALIAS").toString()
                keyPassword = project.property("MYAPP_UPLOAD_KEY_PASSWORD").toString()
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs["release"]
        }
    }
}

flutter {
    source = "../.."
}

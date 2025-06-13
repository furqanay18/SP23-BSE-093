plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.fork_it"
    compileSdk = 34 // or flutter.compileSdkVersion if defined

    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.fork_it"
        minSdk = 21 // or flutter.minSdkVersion
        targetSdk = 34 // or flutter.targetSdkVersion
        versionCode = 1 // or flutter.versionCode
        versionName = "1.0" // or flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
        freeCompilerArgs += listOf("-Xjvm-default=all") // Optional for plugin compatibility
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
            signingConfig = signingConfigs.getByName("debug") // Use real signing config for production
        }
    }
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")
}

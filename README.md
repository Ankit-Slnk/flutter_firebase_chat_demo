# Flutter Firebase Chat Demo

This demo will show us how to make chat app using firebase.

## Setup

Use latest versions of below mentioned plugins in `pubspec.yaml`.

| Plugin | Pub | Explanation |
|--------|-----|-------------|
| [connectivity](https://github.com/flutter/plugins/tree/master/packages/connectivity/connectivity) | [![pub package](https://img.shields.io/pub/v/connectivity.svg)](https://pub.dev/packages/connectivity) | Used to check internet connectivity. 
| [firebase_auth](https://github.com/FirebaseExtended/flutterfire) | [![pub package](https://img.shields.io/pub/v/firebase_auth.svg)](https://pub.dev/packages/firebase_auth) | Used to authenticate phone.
| [firebase_core](https://github.com/FirebaseExtended/flutterfire) | [![pub package](https://img.shields.io/pub/v/firebase_core.svg)](https://pub.dev/packages/firebase_core) | Used for core Firebase Api.
| [shared_preferences](https://github.com/flutter/plugins) | [![pub package](https://img.shields.io/pub/v/shared_preferences.svg)](https://pub.dev/packages/shared_preferences) | Used to store data locally in key-value pairs.
| [fluttertoast](https://github.com/PonnamKarthik/FlutterToast) | [![pub package](https://img.shields.io/pub/v/fluttertoast.svg)](https://pub.dev/packages/fluttertoast) | Used to show toast.
| [cached_network_image](https://github.com/Baseflow/flutter_cached_network_image) | [![pub package](https://img.shields.io/pub/v/cached_network_image.svg)](https://pub.dev/packages/cached_network_image) | Used to load and cache network images.
| [firebase_storage](https://github.com/FirebaseExtended/flutterfire) | [![pub package](https://img.shields.io/pub/v/firebase_storage.svg)](https://pub.dev/packages/firebase_storage) | Provides Firebase Cloud Storage.
| [image_picker](https://github.com/flutter/plugins) | [![pub package](https://img.shields.io/pub/v/image_picker.svg)](https://pub.dev/packages/image_picker) | Used to select images and taking new pictures.
| [provider_architecture](https://github.com/FilledStacks/provider_architecture) | [![pub package](https://img.shields.io/pub/v/provider_architecture.svg)](https://pub.dev/packages/provider_architecture) | Provides ViewModelBuilder class for building UI FROM the ViewModel.
| [get_it](https://github.com/fluttercommunity/get_it) | [![pub package](https://img.shields.io/pub/v/get_it.svg)](https://pub.dev/packages/get_it) | This is a simple Service Locator.
| [cloud_firestore](https://github.com/FirebaseExtended/flutterfire) | [![pub package](https://img.shields.io/pub/v/cloud_firestore.svg)](https://pub.dev/packages/cloud_firestore) | Cloud Firestore, a cloud-hosted, noSQL database with live synchronization and offline support.
| [after_layout](https://github.com/fluttercommunity/flutter_after_layout) | [![pub package](https://img.shields.io/pub/v/after_layout.svg)](https://pub.dev/packages/after_layout) | Execute code after the first layout of your widget has been performed.
| [photo_view](https://github.com/fireslime/photo_view) | [![pub package](https://img.shields.io/pub/v/photo_view.svg)](https://pub.dev/packages/photo_view) | Provides a gesture sensitive zoomable widget.

And then

    flutter pub get

Visit [Firebase Console](https://console.firebase.google.com/u/0/?pli=1) to add new project. Add `Android` and `iOS` app to that project. Add `google-services.json` and `GoogleService-Info.plist` for `Android` and `iOS` respetively to its predefined place in flutter project.

Now enable `Anonymous` Sign-in method (second tab) in Authentication. 

And create Cloud Firestore and Storage below Authentication.

#### For Android

    <uses-permission android:name="android.permission.INTERNET" />

Please mention `internet` permission in `AndroidManifest.xml`. This will not affect in `debug` mode but in `release` mode it will give `socket exception`.

Add SHA-1 in firebase app 

    1. Open app in Android Studio
    2. Open Gradle panel
    3. Goto andoid -> app -> Tasks -> android
    4. Double click on signingReport, it will generate SHA-1

Add below line in android/build.gradle

    buildscript {
        repositories {
            // ...
            mavenLocal()
        }

        dependencies {
            // ...
            classpath 'com.google.gms:google-services:4.3.2'
        }
    }

    allprojects {
        repositories {
            // ...
            mavenLocal()
        }
    }

Add below line in app/build.gradle

    apply plugin: 'com.android.application'

    android {
        // ...
    }

    dependencies {
        // ...
    }

    // ADD THIS AT THE BOTTOM
    apply plugin: 'com.google.gms.google-services'

#### For iOS

Finally

    flutter run

##### Please refer to my [blogs](https://ankitsolanki.netlify.app/blog.html) for more information.



# Plugin for Flutter

Official Jumio Mobile SDK plugin for Flutter

This plugin is compatible with version 4.1.0 of the Jumio SDK. If you have questions, please reach out to your Account Manager or contact [Jumio Support](#support).

# Table of Contents
- [Compatibility](#compatibility)
- [Setup](#setup)
- [Integration](#integration)
 - [iOS](#ios)
 - [Android](#android)
- [Usage](#usage)
   - [Retrieving Information](#retrieving-information)
- [Customization](#customization)
- [Callbacks](#callbacks)
- [Result Objects](#result-objects)
- [FAQ](#faq)
   - [App Crash at Launch for iOS](#app-crash-at-launch-for-ios)
   - [iOS Localization](#ios-localization)
   - [iProov String Keys](#iproov-string-keys)
   - [Empty Country List for Android Release Build](#empty-country-list-for-android-release-build)
- [Support](#support)

## Compatibility
Compatibility has been tested with a Flutter version of 2.10.3 and Dart 2.16.1

## Setup
Create Flutter project and add the Jumio Mobile SDK module to it.

```sh
flutter create MyProject
```

Add the Jumio Mobile SDK as a dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter:
    sdk: flutter

  jumio_mobile_sdk_flutter: ^4.1.0
```

And install the dependency:

```sh
cd MyProject
flutter pub get
```

## Integration

### iOS

1. Add the "**NSCameraUsageDescription**"-key to your Info.plist file.    
2. Your app's deployment target must be at least iOS 11.0

### Android
__AndroidManifest__    
Open your AndroidManifest.xml file and change `allowBackup` to false. Add user permission `HIGH_SAMPLING_RATE_SENSORS` to access sensor data with a sampling rate greater than 200 Hz.

```xml
<application
...
android:allowBackup="false">
</application>
...
<uses-permission android:name="android.permission.HIGH_SAMPLING_RATE_SENSORS"/>
```

Make sure your compileSdkVersion, minSdkVersion and buildToolsVersion are high enough.

```groovy
android {
  minSdkVersion 21
  compileSdkVersion 31
  buildToolsVersion "32.0.0"
  ...
}
```

__Enable MultiDex__   
Follow the Android developers guide: https://developer.android.com/studio/build/multidex.html

```groovy
android {
  ...
  defaultConfig {
    ...
    multiDexEnabled true
  }
}
```

__Upgrade Gradle build tools__    
The plugin requires at least version 4.0.0 of the Android build tools. This transitively requires and upgrade of the Gradle wrapper to version 7 and an update to Java 11.

Upgrade build tools version to 7.0.3 in android/build.gradle:

```groovy
buildscript {
  ...
  dependencies {
    ...
    classpath 'com.android.tools.build:gradle:7.0.3'
  }
}
```

Modify the Gradle Wrapper version in android/gradle.properties.

***Proguard Rules***    
For information on Android Proguard Rules concerning the Jumio SDK, please refer to our [Android guides](https://github.com/Jumio/mobile-sdk-android#proguard).

To enable analytic feedback and internal diagnostics, please make sure to include the line
```
-keep class io.flutter.embedding.android.FlutterActivity
```
to your Proguard Rules.

## Usage

1. Import "**jumiomobilesdk.dart**"

```dart
import 'package:jumio_mobile_sdk_flutter/jumio_mobile_sdk_flutter.dart';
```

2. The SDKs can be initialized with the following call:

```dart
Jumio.init("AUTHORIZATION_TOKEN", "DATACENTER");
```

Datacenter can either be **US**, **EU** or **SG**.      
For more information about how to obtain an `AUTHORIZATION_TOKEN`, please refer to our [API Guide](https://github.com/Jumio/implementation-guides/blob/master/api-guide/api_guide.md).

3. As soon as the SDK is initialized, the SDK is started by the following call.

```dart
Jumio.start();
```

### Retrieving information
Scan results are returned from the startXXX() methods asynchronously. Await the returned values to get the results. Exceptions are thrown issues such as invalid credentials, missing API keys, permissions errors and such.

## Customization
### Android
The JumioSDK colors can be customized by overriding the custom theme `AppThemeCustomJumio`. An example customization of all values that can be found in the [styles.xml of the DemoApp](example/android/app/src/main/res/values/styles.xml)

## Callbacks
In oder to get information about result fields, Retrieval API, Delete API, global settings and more, please read our [page with server related information](https://github.com/Jumio/implementation-guides/blob/master/api-guide/api_guide.md#callback).

## Result Objects
JumioSDK will return `EventResult` in case of a successfully completed workflow and `EventError` in case of error. `EventError` includes an error code and an error message.

### EventResult

| Parameter | Type | Max. length | Description  |
|:-------------------|:-----------     |:-------------|:-----------------|
| selectedCountry | String| 3| [ISO 3166-1 alpha-3](http://en.wikipedia.org/wiki/ISO_3166-1_alpha-3) country code as provided or selected |
| selectedDocumentType | String | 16| PASSPORT, DRIVER_LICENSE, IDENTITY_CARD or VISA |
| idNumber | String | 100 | Identification number of the document |
| personalNumber | String | 14| Personal number of the document|
| issuingDate | Date | | Date of issue |
| expiryDate | Date | | Date of expiry |
| issuingCountry | String | 3 | Country of issue as ([ISO 3166-1 alpha-3](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3)) country code |
| lastName | String | 100 | Last name of the customer|
| firstName | String | 100 | First name of the customer|
| dob | Date | | Date of birth |
| gender | String | 1| m, f or x |
| originatingCountry | String | 3|Country of origin as ([ISO 3166-1 alpha-3](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3)) country code |
| addressLine | String | 64 | Street name    |
| city | String | 64 | City |
| subdivision | String | 3 | Last three characters of [ISO 3166-2:US](http://en.wikipedia.org/wiki/ISO_3166-2:US) state code    |
| postCode | String | 15 | Postal code |
| mrzData |  MRZ-DATA | | MRZ data, see table below |
| optionalData1 | String | 50 | Optional field of MRZ line 1 |
| optionalData2 | String | 50 | Optional field of MRZ line 2 |
| placeOfBirth | String | 255 | Place of Birth |

### MRZ-Data

| Parameter |Type | Max. length | Description |
|:---------------|:------------- |:-------------|:-----------------|
| format | String |  8| MRP, TD1, TD2, CNIS, MRVA, MRVB or UNKNOWN |
| line1 | String | 50 | MRZ line 1 |
| line2 | String | 50 | MRZ line 2 |
| line3 | String | 50| MRZ line 3 |
| idNumberValid | BOOL| | True if ID number check digit is valid, otherwise false |
| dobValid | BOOL | | True if date of birth check digit is valid, otherwise false |
| expiryDateValid |    BOOL| |    True if date of expiry check digit is valid or not available, otherwise false|
| personalNumberValid | BOOL | | True if personal number check digit is valid or not available, otherwise false |
| compositeValid | BOOL | | True if composite check digit is valid, otherwise false |

## FAQ

### App Crash at Launch for iOS
If iOS application crashes immediately after launch and without additional information, but works fine for Android, please make sure to the following lines have been added to your `podfile`:

```
post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
          config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
      end
    end
end
```
Please refer to [iOS guide](https://github.com/Jumio/mobile-sdk-ios#via-cocoapods) for more details.

### iOS Localization
After installing Cocoapods, please localize your iOS application using the languages provided at the following path:   
`ios -> Pods -> Jumio -> Localizations -> xx.lproj`

![Localization](images/Flutter_localization.gif)

### iProov String Keys
Please note that as of 3.8.0. the following keys have been added to the SDK:

* `"IProov_IntroFlash"`
* `"IProov_IntroLa"`
* `"IProov_PromptLivenessAlignFace"`
* `"IProov_PromptLivenessNoTarget"`
* `"IProov_PromptLivenessScanCompleted"`
* `"IProov_PromptTooClose"`
* `"IProov_PromptTooFar"`

Make sure your `podfile` is up to date and that new pod versions are installed properly so your `Localizable` files include new strings.
For more information, please refer to our [Changelog](https://github.com/Jumio/mobile-sdk-ios/blob/master/docs/changelog) and [Transition Guide](https://github.com/Jumio/mobile-sdk-ios/blob/master/docs/transition-guide_id-verification-fastfill.md#3.8.0).

### Empty Country List for Android Release Build
If country list is empty for the Android release build, please make sure your app has the proper internet permissions. Without a working network connection, countries won't load in and the list will stay empty.

If necessary, please add `android.permission.INTERNET` permission to your `AndroidManifest.xml` file.

The standard Flutter template will not include this tag automatically, but still allows Internet access during development to enable communication between Flutter tools and a running app. For more information, please refer to the [official Flutter documentation.](https://flutter.dev/docs/deployment/android#reviewing-the-app-manifest)

# Support

## Contact
If you have any questions regarding our implementation guide please contact Jumio Customer Service at support@jumio.com or https://support.jumio.com. The Jumio online helpdesk contains a wealth of information regarding our service including demo videos, product descriptions, FAQs and other things that may help to get you started with Jumio. Check it out at: https://support.jumio.com.

## Licenses
The software contains third-party open source software. For more information, please see [Android licenses](https://github.com/Jumio/mobile-sdk-android/tree/master/licenses) and [iOS licenses](https://github.com/Jumio/mobile-sdk-ios/tree/master/licenses)

This software is based in part on the work of the Independent JPEG Group.

## Copyright
&copy; Jumio Corp. 268 Lambert Avenue, Palo Alto, CA 94306

The source code and software available on this website (“Software”) is provided by Jumio Corp. or its affiliated group companies (“Jumio”) "as is” and any express or implied warranties, including, but not limited to, the implied warranties of merchantability and fitness for a particular purpose are disclaimed. In no event shall Jumio be liable for any direct, indirect, incidental, special, exemplary, or consequential damages (including but not limited to procurement of substitute goods or services, loss of use, data, profits, or business interruption) however caused and on any theory of liability, whether in contract, strict liability, or tort (including negligence or otherwise) arising in any way out of the use of this Software, even if advised of the possibility of such damage.
In any case, your use of this Software is subject to the terms and conditions that apply to your contractual relationship with Jumio. As regards Jumio’s privacy practices, please see our privacy notice available here: [Privacy Policy](https://www.jumio.com/legal-information/privacy-policy/).

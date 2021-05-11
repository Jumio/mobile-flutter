# Plugin for Flutter

Official Jumio Mobile SDK plugin for Flutter

This plugin is compatible with version 3.9.1 of the Jumio SDK. If you have questions, please reach out to your Account Manager or contact [Jumio Support](#support).

# Table of Contents
- [Compatibility](#compatibility)
- [Setup](#setup)
- [Integration](#integration)
 - [iOS](#ios)
 - [Android](#android)
- [Usage](#usage)
   - [Netverify & Fastfill](#Netverify-&-Fastfill)
   - [Document Verification](#document-verification)
   - [BAM Checkout](#bam-checkout)
   - [Android Netverify eMRTD](#android-netverify-emrtd)
   - [Retrieving Information](#retrieving-information)
- [Customization](#customization)
- [FAQ](#faq)
   - [App Crash at Launch for iOS](#app-crash-at-launch-for-ios)
   - [iOS Localization](#ios-localization)
   - [iProov String Keys](#iproov-string-keys)
- [Result Objects](#result-objects)
- [Support](#support)

## Compatibility
Compatibility has been tested with a Flutter version of 2.0.1 and Dart 2.12

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

  jumio_mobile_sdk_flutter: ^3.9.1
```

And install the dependency:

```sh
cd MyProject
flutter pub get
```

## Integration

### iOS

1. Add the "**NSCameraUsageDescription**"-key to your Info.plist file.
2. Your app's deployment target must be at least iOS 10.0

### Android

1. Open your AndroidManifest.xml file and change allowBackup to false.

```xml
<application
...
android:allowBackup="false">
...
</application>
```

2. Make sure your compileSdkVersion, minSdkVersion and buildToolsVersion are high enough.

```groovy
android {
  minSdkVersion 19
  compileSdkVersion 29
  buildToolsVersion "29.0.3"
  ...
}
```

3. Enable MultiDex
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

4. Upgrade Gradle build tools
The plugin requires at least version 4.0.0 of the android build tools. This transitively requires and upgrade of the Gradle wrapper to version 6.
Without this change the Gradle build will fail with a Jetifier error about bcprov.

Upgrade build tools version to 4.1.2 in android/build.gradle:

```groovy
buildscript {
  ...
  dependencies {
    ...
    classpath 'com.android.tools.build:gradle:4.1.2'
  }
}
```

Modify the Gradle Wrapper version in android/gradle.properties.

## Usage

1. Import "**jumiomobilesdk.dart**"

```dart
import 'package:jumio_mobile_sdk_flutter/jumio_mobile_sdk_flutter.dart';
```

2. The SDKs can be initialized with the following calls

```dart
JumioMobileSDK.initNetverify(<API_TOKEN>, <API_SECRET>, <DATACENTER>, {configuration});
JumioMobileSDK.initDocumentVerification(<API_TOKEN>, <API_SECRET>, <DATACENTER>, {configuration});
JumioMobileSDK.initBAM(<API_TOKEN>, <API_SECRET>, <DATACENTER>, {configuration});
```

Datacenter can either be **US**, **EU** or **SG**.

## Usage

### Netverify & Fastfill
To initialize the SDK, perform the following call.

```dart
JumioMobileSDK.initNetverify(<API_TOKEN>, <API_SECRET>, <DATACENTER>, {configuration});
```

Datacenter can either be **US**, **EU** or **SG**.

Configure the SDK with the *configuration*-Object.

| Configuration | Datatype | Description |
| ------ | -------- | ----------- |
| enableVerification | Boolean | Enable ID verification |
| callbackUrl | String | Specify an URL for individual transactions |
| enableIdentityVerification | Boolean | Enable face match during the ID verification for a specific transaction |
| preselectedCountry | Boolean | Specify the issuing country (ISO 3166-1 alpha-3 country code) |
| customerInternalReference | String | Allows you to identify the scan (max. 100 characters) |
| reportingCriteria | String | Use this option to identify the scan in your reports (max. 100 characters) |
| userReference | String | Set a customer identifier (max. 100 characters) |
| sendDebugInfoToJumio | Boolean | Send debug information to Jumio. |
| dataExtractionOnMobileOnly | Boolean | Limit data extraction to be done on device only |
| cameraPosition | String | Which camera is used by default. Can be **FRONT** or **BACK**. |
| preselectedDocumentVariant | String | Which types of document variants are available. Can be **PAPER** or **PLASTIC** |
| documentTypes | String-Array | An array of accepted document types: Available document types: **PASSPORT**, **DRIVER_LICENSE**, **IDENTITY_CARD**, **VISA** |
| enableWatchlistScreening | String | Enables [Jumio Screening](https://www.jumio.com/screening/). Can be **ENABLED**, **DISABLED** or **DEFAULT** (when not specified reverts to **DEFAULT**) |
| watchlistSearchProfile | String | Specifies specific profile of watchlist |

Initialization example with configuration.

```dart
JumioMobileSDK.initNetverify("API_TOKEN", "API_SECRET", "US", {
  "enableVerification": true,
  "enableIdentityVerification": true,
  "userReference": "CUSTOMERID",
  "preselectedCountry": "USA",
  "cameraPosition": "BACK",
  "documentTypes": ["DRIVER_LICENSE", "PASSPORT", "IDENTITY_CARD", "VISA"],
  "enableWatchlistScreening": "ENABLED",
  "watchlistSearchProfile": "YOURPROFILENAME"
});
```

***Android eMRTD scanning***

If you are using eMRTD scanning, following lines are needed in your `proguard-rules.pro` file:

```
-keep class net.sf.scuba.smartcards.IsoDepCardService {*;}
-keep class org.jmrtd.** { *; }
-keep class net.sf.scuba.** {*;}
-keep class org.bouncycastle.** {*;}
-keep class org.ejbca.** {*;}

-dontwarn java.nio.**
-dontwarn org.codehaus.**
-dontwarn org.ejbca.**
-dontwarn org.bouncycastle.**
```

Add the needed dependencies following [this chapter](https://github.com/Jumio/mobile-sdk-android/blob/master/docs/integration_id-verification-fastfill.md#dependencies) of the android integration guide.

As soon as the SDK is initialized, the SDK is started by the following call.

```dart
JumioMobileSDK.startNetverify();
```

### Document Verification
To initialize the SDK, perform the following call.

```dart
JumioMobileSDK.initDocumentVerification(<API_TOKEN>, <API_SECRET>, <DATACENTER>, {configuration});
```

Datacenter can either be **US**, **EU** or **SG**.

Configure the SDK with the *configuration*-Object. **(configuration marked with * are mandatory)**

| Configuration | Datatype | Description |
| ------ | -------- | ----------- |
| **type*** | String | See the list below |
| **userReference*** | String | Set a customer identifier (max. 100 characters) |
| **country*** | String | Set the country (ISO-3166-1 alpha-3 code) |
| **customerInternalReference*** | String | Allows you to identify the scan (max. 100 characters) |
| reportingCriteria | String | Use this option to identify the scan in your reports (max. 100 characters) |
| callbackUrl | String | Specify an URL for individual transactions |
| documentName | String | Override the document label on the help screen |
| customDocumentCode | String | Set your custom document code (set in the merchant backend under "Settings" - "Multi Documents" - "Custom" |
| cameraPosition | String | Which camera is used by default. Can be **FRONT** or **BACK**. |

Possible types:

*  BS (Bank statement)
*  IC (Insurance card)
*  UB (Utility bill, front side)
*  CAAP (Cash advance application)
*  CRC (Corporate resolution certificate)
*  CCS (Credit card statement)
*  LAG (Lease agreement)
*  LOAP (Loan application)
*  MOAP (Mortgage application)
*  TR (Tax return)
*  VT (Vehicle title)
*  VC (Voided check)
*  STUC (Student card)
*  HCC (Health care card)
*  CB (Council bill)
*  SENC (Seniors card)
*  MEDC (Medicare card)
*  BC (Birth certificate)
*  WWCC (Working with children check)
*  SS (Superannuation statement)
*  TAC (Trade association card)
*  SEL (School enrollment letter)
*  PB (Phone bill)
*  USSS (US social security card)
*  SSC (Social security card)
*  CUSTOM (Custom document type)

Initialization example with configuration.

```dart
await JumioMobileSDK.initDocumentVerification(API_TOKEN, API_SECRET, DATACENTER, {
  "type": "BS",
  "userReference": "123456789",
  "country": "USA",
  "customerInternalReference": "123456789",
  //"reportingCriteria": "Criteria",
  //"callbackUrl": "URL",
  //"documentName": "Name",
  //"customDocumentCode": "Custom",
  //"cameraPosition": "back",
  //"enableExtraction": true
});
```

As soon as the SDK is initialized, the SDK is started by the following call.

```dart
final String result = await JumioMobileSDK.startDocumentVerification();
```

### BAM Checkout
To Initialize the SDK, perform the following call.

```dart
JumioMobileSDK.initBAM(<API_TOKEN>, <API_SECRET>, <DATACENTER>, {configuration});
```

Datacenter can either be **US**, **EU** or **SG**.

Configure the SDK with the *configuration*-Object.

| Configuration | Datatype | Description |
| ------ | -------- | ----------- |
| cardHolderNameRequired | Boolean |
| sortCodeAndAccountNumberRequired | Boolean |
| expiryRequired | Boolean |
| cvvRequired | Boolean |
| expiryEditable | Boolean |
| cardHolderNameEditable | Boolean |
| reportingCriteria | String | Overwrite your specified reporting criteria to identify each scan attempt in your reports (max. 100 characters)
| vibrationEffectEnabled | Boolean |
| enableFlashOnScanStart | Boolean |
| cardNumberMaskingEnabled | Boolean |
| offlineToken | String | In your Jumio merchant backend on the "Settings" page under "API credentials" you can find your Offline token. In case you use your offline token, you must not set the API token and secret|
| cameraPosition | String | Which camera is used by default. Can be **FRONT** or **BACK**. |
| cardTypes | String-Array | An array of accepted card types. Available card types: **VISA**, **MASTER_CARD**, **AMERICAN_EXPRESS**, **CHINA_UNIONPAY**, **DINERS_CLUB**, **DISCOVER**, **JCB** |

Initialization example with configuration.

```dart
await JumioMobileSDK.initBAM(API_TOKEN, API_SECRET, DATACENTER, {
  "cardHolderNameRequired": false,
  "cvvRequired": true,
  "cameraPosition": "BACK",
  "cardTypes": ["VISA", "MASTER_CARD"]
});
```

As soon as the SDK is initialized, the SDK is started by the following call.

```dart
bool result = await JumioMobileSDK.startBAM();
```

### Retrieving information
Scan results are returned from the startXXX() methods asynchronously. Await the returned values to get the results. Exceptions are thrown issues such as invalid credentials, missing API keys, permissions errors and such.

## Customization

### Android

#### Netverify
The Netverify SDK can be customized to the respective needs by following this [customization chapter](https://github.com/Jumio/mobile-sdk-android/blob/v3.9.1/docs/integration_id-verification-fastfill.md#customization).

#### BAM Checkout
The BAM Checkout SDK can be customized to the respective needs by following this [customization chapter](https://github.com/Jumio/mobile-sdk-android/blob/v3.9.1/docs/integration_bam-checkout.md#customization).

#### Document Verification
The Document Verification SDK can be customized to the respective needs by following this [customization chapter](https://github.com/Jumio/mobile-sdk-android/blob/v3.9.1/docs/integration_document-verification.md#customization).


### iOS
The SDK can be customized to the respective needs by using the following initializers instead.
```dart
JumioMobileSDKNetverify.initNetverify(<API_TOKEN>, <API_SECRET>, <DATACENTER>, {configuration}, {customization});
JumioMobileSDKDocumentVerification.initDocumentVerification(<API_TOKEN>, <API_SECRET>, <DATACENTER>, {configuration}, {customization});
JumioMobileSDKBamCheckout.initBAM(<API_TOKEN>, <API_SECRET>, <DATACENTER>, {configuration}, {customization});
```

You can pass the following customization options to the initializer:

| Customization key | Type | Description |
|:------------------|:-----|:------------|
| disableBlur       | BOOL | Deactivate the blur effect |
| backgroundColor   | STRING | Change base view's background color |
| foregroundColor   | STRING | Change base view's foreground color |
| tintColor         | STRING | Change the tint color of the navigation bar |
| barTintColor      | STRING | Change the bar tint color of the navigation bar |
| textTitleColor    | STRING | Change the text title color of the navigation bar |
| documentSelectionHeaderBackgroundColor | STRING | Change the background color of the document selection header |
| documentSelectionHeaderTitleColor | STRING | Change the title color of the document selection header |
| documentSelectionHeaderIconColor | STRING | Change the icon color of the document selection header |
| documentSelectionButtonBackgroundColor | STRING | Change the background color of the document selection button |
| documentSelectionButtonTitleColor | STRING | Change the title color of the document selection button |
| documentSelectionButtonIconColor | STRING | Change the icon color of the document selection button |
| fallbackButtonBackgroundColor | STRING | Change the background color of the fallback button |
| fallbackButtonBorderColor | STRING | Change the border color of the fallback button |
| fallbackButtonTitleColor | STRING | Change the title color of the fallback button |
| positiveButtonBackgroundColor | STRING | Change the background color of the positive button |
| positiveButtonBorderColor | STRING | Change the border color of the positive button |
| positiveButtonTitleColor | STRING | Change the title color of the positive button |
| negativeButtonBackgroundColor | STRING | Change the background color of the negative button |
| negativeButtonBorderColor | STRING | Change the border color of the negative button |
| negativeButtonTitleColor | STRING | Change the title color of the negative button |
| scanOverlayStandardColor (NV only) | STRING | Change the standard color of the scan overlay |
| scanOverlayValidColor (NV only) | STRING | Change the valid color of the scan overlay |
| scanOverlayInvalidColor (NV only) | STRING | Change the invalid color of the scan overlay |
| scanOverlayTextColor (BAM only) | STRING | Change the text color of the scan overlay |
| scanOverlayBorderColor (BAM only) | STRING | Change the border color of the scan overlay |

All colors are provided with a HEX string with the following format: #ff00ff.

**Customization example**

```dart
JumioMobileSDK.initNetverify("API_TOKEN", "API_SECRET", "US", {
  "enableVerification": false,
  ...
}, {
  "disableBlur": true,
  "backgroundColor": "#ff00ff",
  "barTintColor": "#ff1298"
);
```

## Result objects
To get information about result fields, Netverify Retrieval API, Netverify Delete API and Global Netverify settings and more, please read our [page with server related information](https://github.com/Jumio/implementation-guides/blob/master/netverify/callback.md).

The Map with all the extracted data that is returned for the specific products is described in the following subchapters:

### Netverify & Fastfill

*NetverifyDocumentData:*

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
| extractionMethod | String | 12| MRZ, OCR, BARCODE, BARCODE_OCR or NONE |

*MRZ-Data*

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

### BAM Checkout

*BAMCardInformation:*

|Parameter | Type | Max. length | Description |
|:----------------------------     |:-------------|:-----------------|:-------------|
| cardType | String |  16| VISA, MASTER_CARD, AMERICAN_EXPRESS, CHINA_UNIONPAY, DINERS_CLUB, DISCOVER, JCB or STARBUCKS |
| cardNumber | String | 16 | Full credit card number |
| cardNumberGrouped | String | 19 | Grouped credit card number |
| cardNumberMasked | String | 19 | First 6 and last 4 digits of the grouped credit card number, other digits are masked with "X" |
| cardExpiryMonth | String | 2 | Month card expires if enabled and readable |
| CardExpiryYear | String | 2 | Year card expires if enabled and readable |
| cardExpiryDate | String | 5 | Date card expires in the format MM/yy if enabled and readable |
| cardCVV | String | 4 | Entered CVV if enabled |
| cardHolderName | String | 100 | Name of the card holder in capital letters if enabled and readable, or as entered if editable |
| cardSortCode | String | 8 | Sort code in the format xx-xx-xx or xxxxxx if enabled, available and readable |
| cardAccountNumber | String | 8 | Account number if enabled, available and readable |
| cardSortCodeValid | BOOL |  | True if sort code valid, otherwise false |
| cardAccountNumberValid | BOOL |  | True if account number code valid, otherwise false |

### Document Verification
No data returned.

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
`ios -> Pods -> JumioMobileSDK -> JumioMobileSDK-3.9.0 -> Localizations -> xx.lproj`

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

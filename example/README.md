# jumiomobilesdk_example

Demonstrates how to use the JumioMobileSDK plugin.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Usage
Adjust your data center in the **credentials.dart** file, open a bash and run the following commands:
```
cd my_project
flutter pub get
cd ios && pod install
```
Afterwards, run your project on a real device with:
```
flutter run
```

Start a specific workflow with an `sdk.token` for authorization. 

__Note:__ Flutter supports Hot Reloads.

## Swift Package Manager

Swift Package Manager requires the local checkout folder name to match the package name (`jumio_mobile_sdk_flutter`). 
Developers should rename the checkout directory if it does not match.

## iOS Example Apps

This repository contains two iOS example applications demonstrating different dependency managers:

- `example` — uses **CocoaPods**
- `example_spm` — uses **Swift Package Manager (SPM)**

Flutter supports switching between CocoaPods and Swift Package Manager. To select which example app to use, configure Flutter accordingly.

### Use CocoaPods example

Disable Swift Package Manager support:

flutter config --no-enable-swift-package-manager

### Use Swift Package Manager (SPM) example

Enable Swift Package Manager support:

flutter config --enable-swift-package-manager

import 'package:flutter/material.dart';
import 'package:jumio_mobile_sdk_flutter/jumio_mobile_sdk_flutter.dart';
import 'package:jumiomobilesdk_example/credentials.dart';

void main() {
  runApp(DemoApp());
}

class DemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomePage(
          title: "Mobile SDK Demo App",
        ));
  }
}

class HomePage extends StatefulWidget {
  final String title;

  HomePage({Key key, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState(title);
}

class _HomePageState extends State<HomePage> {
  final String title;

  _HomePageState(this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: IntrinsicWidth(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              RaisedButton(
                child: Text("Start Netverify"),
                onPressed: () {
                  _startNetverify();
                },
              ),
              RaisedButton(
                child: Text("Start Document Verification"),
                onPressed: () {
                  startDocumentVerification();
                },
              ),
              RaisedButton(
                child: Text("Start BAM Checkout"),
                onPressed: () {
                  startBam();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startNetverify() async {
    await _logErrors(() async {
      await JumioMobileSDK.initNetverify(API_TOKEN, API_SECRET, DATACENTER, {
        "enableVerification": true,
        //"callbackUrl": "URL",
        //"enableIdentityVerification": true,
        //"preselectedCountry": "USA",
        //"customerInternalReference": "123456789",
        //"reportingCriteria": "Criteria",
        //"userReference": "ID",
        //"sendDebugInfoToJumio": true,
        //"dataExtractionOnMobileOnly": false,
        //"cameraPosition": "back",
        //"preselectedDocumentVariant": "plastic",
        //"documentTypes": ["PASSPORT", "DRIVER_LICENSE", "IDENTITY_CARD", "VISA"],
        //"enableWatchlistScreening": ["enabled", "disabled" || "default"],
        //"watchlistSearchProfile": "YOURPROFILENAME",
      });
      final result = await JumioMobileSDK.startNetverify();
      await _showDialogWithMessage("Netverify has completed. Result: $result");
    });
  }

  Future<void> startDocumentVerification() async {
    await _logErrors(() async {
      await JumioMobileSDK.initDocumentVerification(
          API_TOKEN, API_SECRET, DATACENTER, {
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
      final result = await JumioMobileSDK.startDocumentVerification();
      await _showDialogWithMessage(
          "Document verification completed with result: " + result.toString());
    });
  }

  Future<void> startBam() async {
    await _logErrors(() async {
      await JumioMobileSDK.initBAM(
          BAM_API_TOKEN, BAM_API_SECRET, BAM_DATACENTER, {
//      "cardHolderNameRequired": true,
//      "sortCodeAndAccountNumberRequired": false,
//      "expiryRequired": true,
//      "cvvRequired": true,
//      "expiryEditable": false,
//      "cardHolderNameEditable": false,
//      "reportingCriteria": "Criteria",
//      "vibrationEffectEnabled": true,
//      "enableFlashOnScanStart": false,
//      "cardNumberMaskingEnabled": false,
//      "offlineToken": "TOKEN",
//      "cameraPosition": "back",
//      "cardTypes": [
//        "VISA",
//        "MASTER_CARD",
//        "AMERICAN_EXPRESS",
//        "CHINA_UNIONPAY",
//        "DINERS_CLUB",
//        "DISCOVER",
//        "JCB"
//      ]
      });
      final result = await JumioMobileSDK.startBAM();
      await _showDialogWithMessage("BAM checkout result: $result");
    });
  }

  Future<void> _logErrors(Future<void> Function() block) async {
    try {
      await block();
    } catch (error) {
      await _showDialogWithMessage(error.toString(), "Error");
    }
  }

  Future<void> _showDialogWithMessage(String message,
      [String title = "Result"]) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(child: Text(message)),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

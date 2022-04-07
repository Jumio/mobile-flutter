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
  final String? title;

  HomePage({Key? key, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState(title);
}

class _HomePageState extends State<HomePage> {
  final String? title;
  final tokenInputController = TextEditingController();

  _HomePageState(this.title);

  @override
  void dispose() {
    tokenInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title!),
      ),
      body: Center(
        child: IntrinsicWidth(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                width: 250.0,
                child: TextFormField(
                  controller: tokenInputController,
                  decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Authorization token'),
                ),
              ),
              ElevatedButton(
                child: Text("Start"),
                onPressed: () {
                  _start(tokenInputController.text);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _start(String authorizationToken) async {
    await _logErrors(() async {
      await Jumio.init(authorizationToken, DATACENTER);
      final result = await Jumio.start();
      await _showDialogWithMessage("Jumio has completed. Result: $result");
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
            TextButton(
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

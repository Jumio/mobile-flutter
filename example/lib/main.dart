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
  bool pressedUS = false;
  bool pressedEU = false;
  bool pressedSGP = false;

  _HomePageState(this.title);

  @override
  void initState() {
    super.initState();
    initModelPreloading();
  }

  void initModelPreloading() {
    Jumio.setPreloaderFinishedBlock(() {
      print('All models are preloaded. You may start the SDK now!');
    });
    Jumio.preloadIfNeeded();
  }

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
              ElevatedButton(
                child: Text("US"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: pressedUS ? Colors.yellow : Colors.blue, // background
                  foregroundColor: Colors.white, // foreground
                ),
                onPressed: () => {
                  setState(() {
                    pressedUS = !pressedUS;
                    pressedEU = false;
                    pressedSGP = false;
                  }),
                  DATACENTER = 'US',
                },
              ),
              ElevatedButton(
                child: Text("EU"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: pressedEU ? Colors.yellow : Colors.blue, // background
                  foregroundColor: Colors.white, // foreground
                ),
                onPressed: () => {
                  setState(() {
                    pressedEU = !pressedEU;
                    pressedUS = false;
                    pressedSGP = false;
                  }),
                  DATACENTER = 'EU',
                },
              ),
              ElevatedButton(
                child: Text("SG"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: pressedSGP ? Colors.yellow : Colors.blue, // background
                  foregroundColor: Colors.white, // foreground
                ),
                onPressed: () => {
                  setState(() {
                    pressedSGP = !pressedSGP;
                    pressedUS = false;
                    pressedEU = false;
                  }),
                  DATACENTER = 'SG',
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
      final result = await Jumio.start(
        {
          // "background": "#AC3D9A",
          // "primaryColor": "#FF5722",
          // "loadingCircleIcon": "#F2F233",
          // "loadingCirclePlain": "#57ffc7",
          // "loadingCircleGradientStart": "#EC407A",
          // "loadingCircleGradientEnd": "#bc2e41",
          // "loadingErrorCircleGradientStart": "#AC3D9A",
          // "loadingErrorCircleGradientEnd": "#C31322",
          // "primaryButtonBackground": {"light": "#D900ff00", "dark": "#9Edd9E"}
        }
      );
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
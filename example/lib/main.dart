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
    _checkCachedResult();

    tokenInputController.addListener(() {
      setState(() {});
    });
  }

  Future<void> _checkCachedResult() async {
    await _logErrors(() async {
      final result = await Jumio.getCachedResult();
      if (result != null) {
        await _showDialogWithMessage("Jumio has completed. Result: $result");
      }
    });
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
    double targetWidth = MediaQuery.of(context).size.width * 0.9;

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
                width: targetWidth,
                height: 50,
                margin: const EdgeInsets.only(bottom: 20),
                child: TextFormField(
                  controller: tokenInputController,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    labelText: 'Authorization token',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    suffixIcon: tokenInputController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.cancel),
                      onPressed: () {
                        tokenInputController.clear();
                        setState(() {});
                      },
                    )
                        : null,
                  ),
                ),
              ),

              ElevatedButton(
                child: const Text("Start"),
                onPressed: () {
                  _start(tokenInputController.text);
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                child: const Text("US"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: pressedUS ? Colors.yellow : Colors.blue,
                  foregroundColor: Colors.white,
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
              const SizedBox(height: 4),
              ElevatedButton(
                child: const Text("EU"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: pressedEU ? Colors.yellow : Colors.blue,
                  foregroundColor: Colors.white,
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
              const SizedBox(height: 4),
              ElevatedButton(
                child: const Text("SG"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: pressedSGP ? Colors.yellow : Colors.blue,
                  foregroundColor: Colors.white,
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
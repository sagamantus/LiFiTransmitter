import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Li-Fi Transmitter',
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(),
        useMaterial3: true,
      ),
      home: const LiFiTransmitter(title: 'Li-Fi Transmitter'),
    );
  }
}

class LiFiTransmitter extends StatefulWidget {
  const LiFiTransmitter({super.key, required this.title});

  final String title;

  @override
  State<LiFiTransmitter> createState() => _LiFiTransmitterState();
}

class _LiFiTransmitterState extends State<LiFiTransmitter> {
  final inputController = TextEditingController();
  late List<CameraDescription> cameras;
  late CameraController _controller;

  @override
  void initState() {
    initializeCamera();
    super.initState();
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.low);
    await _controller.initialize();
  }

  Future<void> onFlashlight() async {
    await _controller.setFlashMode(FlashMode.torch);
  }

  Future<void> offFlashlight() async {
    await _controller.setFlashMode(FlashMode.off);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Enter your data and click flashlight button to transmit using flashlight.',
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                autofocus: true,
                autocorrect: false,
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 8,
                decoration: const InputDecoration(
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    borderSide: BorderSide(width: 1),
                  ),
                ),
                controller: inputController,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Encode the text to UTF-8
          List<int> utf8Bytes = utf8.encode(inputController.text);

          // Convert each byte to a list of booleans (true for 1, false for 0)
          List<bool> booleanList = utf8Bytes
              .map((byte) => byte
                  .toRadixString(2)
                  .padLeft(8, '0')
                  .split('')
                  .map((char) => char == '1'))
              .expand((bits) => bits)
              .toList();

          // Traverse the boolean list
          for (bool _bit in booleanList) {
            if (_bit) {
              onFlashlight();
            } else {
              offFlashlight();
            }
            await Future.delayed(Duration(milliseconds: 33));
          }
          offFlashlight();
          // toggleFlashlight();
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text('Data transmitted successfully.'),
              );
            },
          );
        },
        tooltip: 'Transmit',
        child: const Icon(Icons.flashlight_on_rounded),
      ),
    );
  }
}

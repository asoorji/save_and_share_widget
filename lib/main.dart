import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final controller = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Screenshot(
        controller: controller,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Save and Share Widget'),
          ),
          body: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                buildImage(),
                ElevatedButton(
                  child: const Text('Capture Screen'),
                  onPressed: () async {
                    final image = await controller.capture();
                    if (image == null) return;
                    await saveAndShare(image);
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                ElevatedButton(
                  child: const Text('Capture Widget'),
                  onPressed: () async {
                    final image =
                        await controller.captureFromWidget(buildImage());

                    await saveImage(image);
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                ElevatedButton(
                  child: const Text('Share Widget'),
                  onPressed: () async {
                    final image = await controller.captureFromWidget(
                      QrImageView(
                        data: '123456',
                        size: 200.0,
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    );
                    await saveAndShare(image);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildImage() => Stack(
        children: [
          AspectRatio(
              aspectRatio: 1,
              child: Container(
                color: Colors.yellow,
                height: 500,
                width: 500,
              )),
          const Positioned(
              bottom: 16,
              right: 0,
              left: 0,
              child: Center(child: Text('God!!!'))),
        ],
      );

  Future<String> saveImage(Uint8List bytes) async {
    await [Permission.storage].request();
    final name = 'screenshot_Dart_${DateTime.now()}.png';
    final result = await ImageGallerySaver.saveImage(bytes, name: name);
    return result['filePath'];
  }

  Future<void> saveAndShare(Uint8List bytes) async {
    print(000);
    final directory = await getApplicationDocumentsDirectory();
    final image = File('${directory.path}/flutter.png');
    image.writeAsBytesSync(bytes);
    await saveImage(bytes);
    const text = 'MotoPay Scan To Pay';
    await Share.shareFiles([image.path], text: text);
  }
}

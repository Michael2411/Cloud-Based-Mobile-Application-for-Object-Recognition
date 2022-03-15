import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';
import 'dart:io';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();
  runApp(CameraApp());
}

class CameraApp extends StatefulWidget {
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController controller;
  var image = null;
  late List<Plane> image_send;
  late int test = 70;

  get jpeg => null;
  var image_show_1 = Image.network(
      "https://outofschool.club/wp-content/uploads/2015/02/insert-image-here.jpg");

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras[0], ResolutionPreset.low,
        imageFormatGroup: ImageFormatGroup.jpeg);
    //controller = CameraController(cameras[0], ResolutionPreset.low,imageFormatGroup:jpeg);

    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      // IO.Socket socket = IO.io('https://e688-45-243-94-156.ngrok.io',
      //     OptionBuilder().setTransports(['websocket']).build());
      // socket.onConnect((_) {
      //   print('connect');
      // });

      // socket.on('out-image-event', (data) {
      //   var image_show = Image.memory(base64Decode(data["image_data"]));
      //   setState(() {
      //     image_show_1 = image_show;
      //   });
      // });

      // socket.onDisconnect((_) => print('disconnect'));

      int counter = 0;
      controller.startImageStream((image) {
        var imaaaage = base64Encode(image.planes[0].bytes);
        counter = counter + 1;

        // socket.emit('input image1_1', [imaaaage, counter]);
      });
    });
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter Image Demo'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              image_show_1,
              const Text(
                'It is an image displays from the given url.',
                style: TextStyle(fontSize: 20.0),
              )
            ],
          ),
        ),
      ),
    );
  }
}

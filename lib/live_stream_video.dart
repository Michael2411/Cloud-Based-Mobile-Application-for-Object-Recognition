import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';
import 'dart:io';
import 'package:image/image.dart' as imoo;
import 'sound.dart';
import 'globals.dart' as globals;

late List<CameraDescription> cameras;

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class RectanglePainter1 extends CustomPainter {
  var parsedata;
  @override
  void paint(Canvas canvas, Size size) {
    //------------------------------------------
    parsedata = globals.parsedata;
    final widthRatio = 1.5;
    final heightRatio = 1.5;
    double fontSize = 0.05 * size.width;
    for (var dict in parsedata) {
      final a = Offset(dict['xmin'] * widthRatio, dict['ymin'] * heightRatio);
      final b = Offset(dict['xmax'] * widthRatio, dict['ymax'] * heightRatio);
      //drawing rectangle with point a and b
      final rect = Rect.fromPoints(a, b);
      Color predectionColor = Color.fromARGB(255, 200, 200, 200);

      final paint = Paint()
        ..color = predectionColor
        ..strokeWidth = 0.003 * (size.width + size.height)
        ..style = PaintingStyle.stroke;
      canvas.drawRect(rect, paint);
      //------------------------------------------
      //Add name of the predicted object over it's square in the image
      TextSpan span = new TextSpan(
          style: new TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontSize: fontSize,
              backgroundColor: predectionColor,
              fontFamily: 'Roboto'),
          text: " " + dict['name'] + " ");

      TextPainter tp = new TextPainter(
          text: span,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center);

      tp.layout();
      tp.paint(
          canvas,
          new Offset(dict['xmin'] * widthRatio,
              dict['ymin'] * heightRatio - fontSize - 5));
      //------------------------------------------
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

Future<void> main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();
  runApp(CameraApp());
}

class CameraApp extends StatefulWidget {
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  Future<void> camera_starter() async {
    HttpOverrides.global = MyHttpOverrides();
    WidgetsFlutterBinding.ensureInitialized();

    cameras = await availableCameras();
    runApp(CameraApp());
  }

  late CameraImage cameraImage;
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
    camera_starter();
    loadCamera();
  }

  loadCamera() {
    controller = CameraController(cameras[0], ResolutionPreset.low,
        imageFormatGroup: ImageFormatGroup.jpeg);

    controller.initialize().then((_) {
      IO.Socket socket = IO.io('${globals.domain}/test',
          OptionBuilder().setTransports(['websocket']).build());
      socket.onConnect((_) {
        print('connect!!!!!!!!!!!!!!!!!!!!!!!');
      });

      if (!mounted) {
        return;
      } else {
        setState(() {
          int counter = 0;

          controller.startImageStream((image) async {
            cameraImage = image;
            counter = counter + 1;
            if (counter % 30 == 0) {
              print("Image size: ${image.width}x${image.height}");
              var imaaaage = base64Encode(image.planes[0].bytes);

              final decoded_image =
                  await decodeImageFromList(image.planes[0].bytes);
              globals.image_data = decoded_image;

              print(counter);
              socket.emit('input image array', imaaaage);
              var image_show = Image.memory(image.planes[0].bytes);
              // setState(() {
              // image_show_1=image_show;
              // });
            }
          });
        });
      }

      socket.on('out-image-event-array', (data) {
        // data : is the array of dictionary of objects from the server to the client to be used to label each frame
        // todo : #MM: call the drawing function here
        globals.parsedata = data;
        print(data);
      });

      socket.onDisconnect((_) => print('disconnect'));
    });
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter Image Demo'),
        ),
        body: Center(
          // camera stream is displayed here
          child: Stack(
            children: [CameraPreview(controller)],
          ),
        ),
      ),
    );
  }
}

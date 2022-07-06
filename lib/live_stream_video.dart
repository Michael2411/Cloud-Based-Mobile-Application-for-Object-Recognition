import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:graduation_app/UIassets/constants.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';
import 'dart:io';
import 'package:image/image.dart' as imoo;
import 'image_paint_page.dart';
import 'globals.dart' as globals;

// late List<CameraDescription> cameras;

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
//Objects labeling class
class RectanglePainter1 extends CustomPainter {
  var parsedata;
  @override
  void paint(Canvas canvas, Size size) {
    //------------------------------------------
    parsedata = globals.parsedata;
    final widthRatio = 1;
    final heightRatio = 1;
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
  globals.cameras = await availableCameras();
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
    
    globals.cameras = await availableCameras();
  }

  void initialize() async {
    globals.cameras = await availableCameras();
  }

  late CameraController controller;
  var image = null;
  bool start = false;
  late List<Plane> image_send;


  get jpeg => null;
  var image_show_1;

  @override
  void initState() {
    initialize();
    super.initState();
    camera_starter();
    loadCamera();
  }

  loadCamera() {
    //Get controller to the back camera with low resolution to be sent to the server
    initialize();
    controller = CameraController(globals.cameras[0], ResolutionPreset.low,
        imageFormatGroup: ImageFormatGroup.jpeg);

    controller.initialize().then((_) {
      //Establish socket connection
      IO.Socket socket = IO.io('${globals.domain}/test',
          OptionBuilder().setTransports(['websocket']).build());
      socket.onConnect((_) {
      });

      if (!mounted) {
        return;
      } else {
        setState(() {
          int counter = 0;
          controller.startImageStream((image) {
            counter = counter + 1;
            //Adjusting frame rate
            if (counter % 20 == 0) {
              globals.width = image.width;
              globals.height = image.height;
              var sent_image = base64Encode(image.planes[0].bytes);
              //Send frame to the server
              socket.emit('input image array',sent_image);
              setState(() {
                globals.parsedata = [];
              });
            }
          });
        });
      }
      //Receive the detected objects data
      socket.on('out-image-event-array', (data) {
        final parsed = json.decode(data);
        globals.parsedata = parsed;
      //Draw detected objects labels
        setState(() {
          image_show_1 = RectanglePainter1();
          globals.st = true;
        });
      });

      socket.onDisconnect((_) => print('disconnect'));
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: themeColor,
        body: Center(
            child: globals.st
                ? CustomPaint(
                    foregroundPainter: image_show_1,
                    child: CameraPreview(controller),
                  )
                : CameraPreview(controller)),
      ),
    );
  }
}

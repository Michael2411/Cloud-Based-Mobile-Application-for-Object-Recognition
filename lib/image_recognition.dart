import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';
import 'package:camera/camera.dart';

import 'package:http/io_client.dart';
import 'dart:async';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

late List<CameraDescription> cameras;
Future<void> main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppstate();
  }
}

class MyAppstate extends State<MyApp> {
  late CameraController controller;
  String image_url =
      "https://outofschool.club/wp-content/uploads/2015/02/insert-image-here.jpg";

  stream_camira(String title) {
    super.initState();
    controller = CameraController(cameras[0], ResolutionPreset.low,
        imageFormatGroup: ImageFormatGroup.jpeg);
    //controller = CameraController(cameras[0], ResolutionPreset.low,imageFormatGroup:jpeg);

    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      IO.Socket socket = IO.io('https://7e15-41-44-118-135.ngrok.io/test',
          OptionBuilder().setTransports(['websocket']).build());
      socket.onConnect((_) {
        print('connect');
      });

      socket.on('out-image-event', (data) => print(data));
      socket.onDisconnect((_) => print('disconnect'));
      socket.emit('try', "imaaaage");

      controller.startImageStream((image) {
        var imaaaage = base64Encode(image.planes[0].bytes);

        //socket.emit('input image1_1',imaaaage);
        setState(() {});
      });
    });
  }

  uploadImage(String title) async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(
        source: ImageSource.gallery, maxHeight: 500, maxWidth: 500);
    if (pickedFile == null) return;
    var selected_image = File(pickedFile.path);
    var request = http.MultipartRequest(
        "POST", Uri.parse("https://7e15-41-44-118-135.ngrok.io/api/photo"));

    //var request = http.MultipartRequest("POST",Uri.parse("https://7e15-41-44-118-135.ngrok.io/api/array"));
    var picture = http.MultipartFile(
        'file',
        File(pickedFile.path).readAsBytes().asStream(),
        File(pickedFile.path).lengthSync(),
        filename: pickedFile.path.split("/").last);

    //request.files.add(picture);
    request.files.add(picture);

    http.Response response =
        await http.Response.fromStream(await request.send());
    final parsed = json.decode(response.body);
    //print(parsed['image_out']);
    print(parsed['image_array']);
    setState(() {
      image_url = parsed['image_out'];
    });
    //return Image.network('https://47c6-41-44-119-178.ngrok.io/image/dog.jpg');
  }

  uploadImage_camera(String title) async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    if (pickedFile == null) return;
    var selected_image = File(pickedFile.path);

    var request = http.MultipartRequest(
        "POST", Uri.parse("https://7e15-41-44-118-135.ngrok.io/api/photo"));
    var picture = http.MultipartFile(
        'file',
        File(pickedFile.path).readAsBytes().asStream(),
        File(pickedFile.path).lengthSync(),
        filename: pickedFile.path.split("/").last);

    //request.files.add(picture);
    request.files.add(picture);
    http.StreamedResponse ttr = await request.send();
    http.Response response = await http.Response.fromStream(ttr);

    final parsed = json.decode(response.body);
    print("==============");
    print(parsed['image_out']);
    ///////////////////////////json get array
    print(parsed['image_array']);
    setState(() {
      image_url = parsed['image_out'];
    });
    //return Image.network('https://47c6-41-44-119-178.ngrok.io/image/dog.jpg');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Image Upload'),
        ),
        body: Center(
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(image_url, height: 400,
                    loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
              ),
              TextButton(
                onPressed: () {
                  uploadImage(
                    'image',
                  );
                },
                child: Text('Upload'),
              ),
              TextButton(
                onPressed: () {
                  uploadImage_camera(
                    'image',
                  );
                },
                child: Text('from camera'),
              ),
              TextButton(
                onPressed: () {
                  stream_camira(
                    'image',
                  );
                },
                child: Text('stream detection'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

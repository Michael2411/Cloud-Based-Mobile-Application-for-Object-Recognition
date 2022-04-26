import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';
import 'package:camera/camera.dart';
import 'live_stream_video.dart';
import 'package:http/io_client.dart';
import 'dart:async';
import 'main.dart';
import 'image_paint_page.dart';
import 'globals.dart' as globals;
import 'dart:ui' as ui;

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
  runApp(MainMenu());
}

class MainMenu extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppstate();
  }
}

class MyAppstate extends State<MainMenu> {
  late CameraController controller;
  String image_url =
      "https://outofschool.club/wp-content/uploads/2015/02/insert-image-here.jpg";

  uploadImage(String title) async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(
        source: ImageSource.gallery, maxHeight: 500, maxWidth: 500);
    if (pickedFile == null) return;
    //'selected_image' is the image uploaded from the given path 'pickedFile.path'
    var selected_image = File(pickedFile.path);
    var request =
        http.MultipartRequest("POST", Uri.parse("${globals.domain}/api/photo"));

    var picture = http.MultipartFile(
        'file',
        File(pickedFile.path).readAsBytes().asStream(),
        File(pickedFile.path).lengthSync(),
        filename: pickedFile.path.split("/").last);

    final bytes = await selected_image.readAsBytes();
    final image = await decodeImageFromList(bytes);

    globals.image_data = image;
    request.files.add(picture);

    http.Response response =
        await http.Response.fromStream(await request.send());
    final parsed = json.decode(response.body);
    final parsedJSON = (jsonDecode(parsed['image_array']));
    globals.temp_id = parsed['google_api_name'];
    globals.parsedata = parsedJSON;
    print(parsedJSON);

    Navigator.pushNamed(context, '/draw_image');
  }

  uploadImage_camera(String title) async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    if (pickedFile == null) return;
    var selected_image = File(pickedFile.path);

    var request =
        http.MultipartRequest("POST", Uri.parse("${globals.domain}/api/photo"));
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
    final parsedJSON = (jsonDecode(parsed['image_array']));
    globals.temp_id = parsed['google_api_name'];
    globals.parsedata = parsedJSON;
    final bytes = await selected_image.readAsBytes();
    final image = await decodeImageFromList(bytes);

    globals.image_data = image;

    globals.parsedata = parsedJSON;
    print(parsedJSON);

    Navigator.pushNamed(context, '/draw_image');
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
              ElevatedButton(
                onPressed: () {
                  uploadImage(
                    'image',
                  );
                },
                child: Text('Upload'),
              ),
              ElevatedButton(
                onPressed: () {
                  uploadImage_camera(
                    'image',
                  );
                },
                child: Text('from camera'),
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/stream');
                  },
                  child: const Text('Live Stream')),
            ],
          ),
        ),
      ),
    );
  }
}

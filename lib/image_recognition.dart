import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graduation_app/UIassets/constants.dart';
import 'package:graduation_app/customs/background.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

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
  //percentage of quality needed
  var quality = 1;

  //method to compress the images
  Future<File> compressImage(String path, int quality) async {
    final newPath = p.join((await getTemporaryDirectory()).path,
        '${DateTime.now()}.${p.extension(path)}');
    final result = await FlutterImageCompress.compressAndGetFile(path, newPath,
        quality: quality);
    return result!;
  }

  //method to upload image from gallary
  uploadImage(String title) async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
    );
    if (pickedFile == null) return;

    //'selected_image' is the image uploaded from the given path 'pickedFile.path'
    var selected_image = File(pickedFile.path);

    // int sizeInBytes = selected_image.lengthSync();
    // double sizeInMb = sizeInBytes / (1024 * 1024);
    // print('original size = ${sizeInMb}');

    //the compressed image
    var compressedFile = await compressImage(pickedFile.path, 50);

    // sizeInBytes = File(compressedFile.path).lengthSync();
    // sizeInMb = sizeInBytes / (1024 * 1024);
    // print('compressed size = ${sizeInMb}');

    var request =
        http.MultipartRequest("POST", Uri.parse("${globals.domain}/api/photo"));
    request.fields['client_id'] = globals.temp_id;

    // the var sent by the api that contains the image
    var picture = http.MultipartFile(
        'file',
        File(compressedFile.path).readAsBytes().asStream(),
        File(compressedFile.path).lengthSync(),
        filename: pickedFile.path.split("/").last);

    final bytes = await selected_image.readAsBytes();
    final image = await decodeImageFromList(bytes);

    globals.image_data = image;

    request.files.add(picture);

    http.Response response =
        await http.Response.fromStream(await request.send());
    final parsed = json.decode(response.body);
    final parsedJSON = (jsonDecode(parsed['image_array']));
    //globals.temp_id = parsed['google_api_name'];
    globals.parsedata = parsedJSON;
    print(parsedJSON);

    Navigator.pushNamed(context, '/draw_image');
  }

  uploadImage_camera(String title) async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.getImage(source: ImageSource.camera, maxWidth: 1920);

    if (pickedFile == null) return;

    //'selected_image' is the image uploaded from the given path 'pickedFile.path'
    var selected_image = File(pickedFile.path);

    // int sizeInBytes = selected_image.lengthSync();
    // double sizeInMb = sizeInBytes / (1024 * 1024);
    // print('original size = ${sizeInMb}');

    //the compressed image
    var compressedFile = await compressImage(pickedFile.path, 50);

    // sizeInBytes = File(compressedFile.path).lengthSync();
    // sizeInMb = sizeInBytes / (1024 * 1024);
    // print('compressed size = ${sizeInMb}');

    var request =
        http.MultipartRequest("POST", Uri.parse("${globals.domain}/api/photo"));

    // the var sent by the api that contains the image
    var picture = http.MultipartFile(
        'file',
        File(compressedFile.path).readAsBytes().asStream(),
        File(compressedFile.path).lengthSync(),
        filename: pickedFile.path.split("/").last);

    //request.files.add(picture);
    request.files.add(picture);
    request.fields['client_id'] = globals.temp_id;
    http.StreamedResponse ttr = await request.send();
    http.Response response = await http.Response.fromStream(ttr);
    final parsed = json.decode(response.body);
    final parsedJSON = (jsonDecode(parsed['image_array']));
    //globals.temp_id = parsed['google_api_name'];
    globals.parsedata = parsedJSON;
    final bytes = await selected_image.readAsBytes();
    final image = await decodeImageFromList(bytes);

    globals.image_data = image;

    globals.parsedata = parsedJSON;
    print(parsedJSON);

    Navigator.pushNamed(context, '/draw_image');
  }

  get_client_id() async {
    // get client id from data
    var prefs = await SharedPreferences.getInstance();
    globals.temp_id = prefs.getString('client_id') ?? "0";
    print("===============");
    print(globals.temp_id);

    // request client id if it is the first time to use the program and save it in data
    if (globals.temp_id == "0") {
      print("hiiiiiii");
      http.Response response = await http.post(
        Uri.parse("${globals.domain}/api/new_client"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      globals.temp_id = json.decode(response.body).toString();
      print(globals.temp_id);
      prefs.setString('client_id', globals.temp_id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    get_client_id();

    return MaterialApp(
      home: Scaffold(
        backgroundColor: themeColor,
        resizeToAvoidBottomInset: false,
        /* appBar: AppBar(
          title: Image.asset('assets/name.png', fit: BoxFit.cover),
          leading: IconButton(
                  icon: Image.asset('assets/logo.png',height: 100),
                  onPressed: () { },),
          backgroundColor:  themeColor,
          centerTitle: true,
        ),*/
        body: Stack(children: [
          BACKGROUND(
            height: size.height,
            width: size.width,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                children: [
                  Image.asset(
                    'assets/Logo.png',
                    height: size.height / 2.5,
                    width: size.width,
                  ),
                  Image.asset(
                    'assets/name.png',
                    height: size.height / 25,
                  ),
                  /*ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(image_url, height: 0,
                          loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      }),
                    ),*/
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Ink(
                        height: 0.1 * size.height,
                        width: 0.55 * size.width,
                        decoration: const BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(
                                  "assets/gallery.png",
                                ),
                                fit: BoxFit.contain)),
                        child: InkWell(
                          onTap: () {
                            uploadImage(
                              'image',
                            );
                          },
                        )),
                    /*child: ElevatedButton(
                        onPressed: () {
                          uploadImage(
                            'image',
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          textStyle:const TextStyle(
                            color: WHITE,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),),
                        child: Text('Upload'),
                      ),*/
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Ink(
                        height: 0.1 * size.height,
                        width: 0.55 * size.width,
                        decoration: const BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage("assets/camera.png"),
                                fit: BoxFit.contain)),
                        child: InkWell(
                          onTap: () {
                            uploadImage_camera(
                              'image',
                            );
                          },
                        )),
                    /* ElevatedButton(
                        onPressed: () {
                          uploadImage_camera(
                            'image',
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          textStyle:const TextStyle(
                            color: WHITE,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),),
                        child: Text('from camera'),
                      ),*/
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Ink(
                        height: 0.1 * size.height,
                        width: 0.55 * size.width,
                        decoration: const BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage("assets/stream.png"),
                                fit: BoxFit.contain)),
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/stream');
                          },
                        )),
                    /*ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/stream');
                          },
                          style: ElevatedButton.styleFrom(
                            textStyle:const TextStyle(
                              color: WHITE,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),),
                          child: const Text('Live Stream')),*/
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Ink(
                        height: 0.1 * size.height,
                        width: 0.55 * size.width,
                        decoration: const BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage("assets/cloud.png"),
                                fit: BoxFit.contain)),
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/get_cloud');
                          },
                        )),
                    /*ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/get_cloud');
                          },
                          style: ElevatedButton.styleFrom(
                            textStyle:const TextStyle(
                              color: WHITE,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),),
                          child: const Text('open my cloud')),*/
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

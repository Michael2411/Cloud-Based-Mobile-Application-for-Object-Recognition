import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';
import 'dart:io';
import 'package:image/image.dart' as imoo;



late List<CameraDescription> cameras;
 class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
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
  var image_show_1=Image.network("https://outofschool.club/wp-content/uploads/2015/02/insert-image-here.jpg");


  @override
  void initState() {
    super.initState();
    camera_starter();
    loadCamera();
  }

  loadCamera() {
    controller = CameraController(cameras[0], ResolutionPreset.low,imageFormatGroup: ImageFormatGroup.jpeg);

    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
    // IO.Socket socket = IO.io('https://ae1f-41-44-118-31.ngrok.io/test',OptionBuilder().setTransports(['websocket']).build());
    // socket.onConnect((_) {
    //   print('connect!!!!!!!!!!!!!!!!!!!!!!!');

    // });
      else{
        setState(() {
          int counter=0;

          controller.startImageStream((image) {
            cameraImage = image;
            counter=counter+1;
            if (counter%30==0){
              print("Image size: ${image.width}x${image.height}");
              var imaaaage=base64Encode(image.planes[0].bytes);
              print(counter);
              // socket.emit('input image array',imaaaage);
              var image_show=Image.memory(image.planes[0].bytes);
              // setState(() {
              // image_show_1=image_show;
              // });
            }

          });
        });
        
      }
      


    // socket.on('out-image-event-array', (data) {
    //   // data : is the array of dictionary of objects from the server to the client
    //   //todo:#MM:call the grawing function here
    //   print(data);

    // });

  

    // socket.onDisconnect((_) => print('disconnect'));

    


    });
  }



  Widget build(BuildContext context) {  
    return MaterialApp(  
      home: Scaffold(  
        appBar: AppBar(  
            title: Text('Flutter Image Demo'),  
        ),  
        body: Center(  
          child: Container(
              child: !controller.value.isInitialized?
              Container():
              AspectRatio(aspectRatio: controller.value.aspectRatio,
              child: CameraPreview(controller),)
               )    
          ),  
        ),  
    );  
  }  
}

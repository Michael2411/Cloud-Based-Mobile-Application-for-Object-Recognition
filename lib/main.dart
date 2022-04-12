import 'dart:io';
import 'image_recognition.dart';
import 'package:flutter/material.dart';
import 'image_paint_page.dart';
import 'globals.dart' as globals;
import 'sound.dart';
import 'live_stream_video.dart';


class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      routes:<String, WidgetBuilder>{
        '/camera':(context)  => MainMenu(),
        '/home':(context) => HomePage(),  
        '/stream':(context)  => CameraApp(),
        '/draw_image':(context) => ImageAndSound(),       
      },
    );
  }
}

class HomePage extends StatelessWidget{
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return  MaterialApp(
      home: Scaffold(
          appBar:AppBar(title: const Text('Graduation Project'),),
          body:Center(
              child:Column(
                  children:[
                    ElevatedButton(onPressed:(){
                      Navigator.pushNamed(context,'/camera');
                      },
                        child: const Text('Main Menu')),
                  ],
              ),
          ),
      )
    );
  }
}


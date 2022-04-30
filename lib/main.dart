import 'dart:io';
import 'package:graduation_app/customs/background.dart';

import 'image_recognition.dart';
import 'package:flutter/material.dart';
import 'image_paint_page.dart';
import 'globals.dart' as globals;
import 'sound.dart';
import 'live_stream_video.dart';
import 'UIassets/constants.dart';

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
    final Size size= MediaQuery.of(context).size;
    return  MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        resizeToAvoidBottomInset: false,
          appBar:AppBar(title: const Text('Graduation Project',style: TextStyle(color:DARK_RED,fontSize: 40,
                                    fontWeight:FontWeight.bold,fontStyle: FontStyle.italic),),
            backgroundColor: DARK_BLUE,
            centerTitle: true,),
          body:Stack(
            children:[ BACKGROUND(
              height: size.height,
              width: size.width,
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.all(50),
                  child: Column(
                    children:[ ElevatedButton(onPressed:(){
                      Navigator.pushNamed(context,'/camera');
                    },
                        style: ElevatedButton.styleFrom(
                          textStyle:const TextStyle(
                            color: WHITE,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: const Text('Main Menu')),
                ]
                  ),
                ),
              ),
          ]
          ),
      )
    );
  }
}


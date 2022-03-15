import 'dart:io';
import 'pickingImage.dart';
import 'stream.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      routes:<String, WidgetBuilder>{
        '/camera':(context)  => MainScreen(),
        '/home':(context) => HomePage(),
        '/stream':(context) => CameraApp()
      },
    );
  }
}

class HomePage extends StatelessWidget{
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return  Scaffold(
        appBar:  AppBar(title: const Text('Graduation Project'),),
        body:Center(
            child:Column(
                children:[
                  ElevatedButton(onPressed:(){
                    Navigator.pushNamed(context,'/camera');
                    },
                      child: const Text('Go to camera')),
                  ElevatedButton(onPressed:(){
                    Navigator.pushNamed(context,'/stream');
                  },
                      child: const Text('Stream Video')),
                ],
            ),
        ),
    );
  }
}


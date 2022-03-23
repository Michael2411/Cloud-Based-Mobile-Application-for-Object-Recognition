import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:convert';
import 'globals.dart' as globals;
import 'image_paint_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget { 
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ImageAndSound(),
    );
  }
}

class ImageAndSound extends StatefulWidget {
  const ImageAndSound({Key? key}) : super(key: key);

  @override
  State<ImageAndSound> createState() => _ImageAndSoundState();
}

class _ImageAndSoundState extends State<ImageAndSound> {
  final FlutterTts flutterTts = FlutterTts();
  String? _newVoiceText;

  speak() async{
      _newVoiceText = jsonDataToString(globals.parsedata);
      if (_newVoiceText != null) {
      if (_newVoiceText!.isNotEmpty) {
        await flutterTts.speak(_newVoiceText!);
      }
    }
  }

  String jsonDataToString(var jsondata){
    final parsedjson = jsondata;

    //The string to be spoke
    String voiceString = "The image contains ";

    //function to add objects names and their occurance count in a map
    void addToMap(String key, Map data) {
      if (data.containsKey(key)) {
        data[key] += 1;
        return;
      }
      data[key] = 1;
    }

    //The map used in saving data
    Map<String,int>? voiceData = {};
    parsedjson.forEach((dict) =>
      addToMap(dict['name'] , voiceData)
    );

    //Creating the string from the data map
    int count = 1;
    int dictlength = voiceData.keys.length;
    voiceData.forEach((object,number) {
      voiceString += (number !=1? number.toString() + object + "s,": (['a','e','i','o','u'].contains(object[0])? " an ":" a ") + object) + (count == dictlength - 1? " ,and" :" , ");
      count++;
    });

    return voiceString;
  }

@override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: ImagePaintPage(),
        floatingActionButton: 
              FloatingActionButton(
                onPressed: () => speak(),
                tooltip: 'Speak the objects inside the image.',
                child: const Icon(Icons.multitrack_audio)),
              floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        bottomNavigationBar: BottomAppBar(
            color: Colors.blue,
            child: Container(height: 50.0,),
        ),
      ),
    );
  }
}
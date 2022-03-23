import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'page/image_paint_page.dart';
import 'dart:convert';

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
      home: const MyHomePage(title: 'Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

//The jsondata recieved from the cloud (Should be overwritted by data recieved from the cloud)
String jsondata = '[{"xmin":133.753036499,"ymin":217.3223419189,"xmax":308.8097229004,"ymax":544.0966186523,"confidence":0.8930187821,"class":16,"name":"dog"},{"xmin":133.753036499,"ymin":217.3223419189,"xmax":308.8097229004,"ymax":544.0966186523,"confidence":0.8930187821,"class":16,"name":"dog"},{"xmin":471.0671691895,"ymin":75.365020752,"xmax":688.200012207,"ymax":172.7693786621,"confidence":0.7528358102,"class":2,"name":"car"},{"xmin":150.212020874,"ymin":117.9598999023,"xmax":568.2462158203,"ymax":426.2601623535,"confidence":0.4828520119,"class":1,"name":"bicycle"}]';

class _MyHomePageState extends State<MyHomePage> {
  final FlutterTts flutterTts = FlutterTts();
  String? _newVoiceText;

  speak() async{
      _newVoiceText = jsonDataToString(jsondata);
      if (_newVoiceText != null) {
      if (_newVoiceText!.isNotEmpty) {
        await flutterTts.speak(_newVoiceText!);
      }
    }
  }

  String jsonDataToString(String jsondata){
    final parsedjson = jsonDecode(jsondata);

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
        appBar: AppBar(
          title: Text('ObjectDetection Audio'),
        ),
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
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:convert';
import 'globals.dart' as globals;
import 'image_paint_page.dart';
import 'positioned_tap_detector_2.dart';
import 'Search_by_long_press.dart';
import 'package:url_launcher/url_launcher.dart';

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

  speak() async {
    _newVoiceText = jsonDataToString(globals.parsedata);
    if (_newVoiceText != null) {
      if (_newVoiceText!.isNotEmpty) {
        await flutterTts.speak(_newVoiceText!);
      }
    }
  }

  String jsonDataToString(var jsondata) {
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
    Map<String, int>? voiceData = {};
    parsedjson.forEach((dict) => addToMap(dict['name'], voiceData));

    //Creating the string from the data map
    int count = 1;
    int dictlength = voiceData.keys.length;
    voiceData.forEach((object, number) {
      voiceString += (number != 1
              ? number.toString() + object + "s,"
              : (['a', 'e', 'i', 'o', 'u'].contains(object[0])
                      ? " an "
                      : " a ") +
                  object) +
          (count == dictlength - 1 ? " ,and" : " , ");
      count++;
    });

    return voiceString;
  }

  void _onLongPress(TapPosition position) {
    var temp = position.relative.toString();

    var parse = temp.split('(');
    parse = parse[1].split(',');
    double x = double.parse(parse[0]);
    parse = parse[1].split(')');
    double difference = ((MediaQuery.of(context).size.height) -
            (globals.image_data!.height.toDouble())) /
        (2);
    double y = double.parse(parse[0]) - difference;

    int index = get_near_object(globals.parsedata, x, y);

    print(globals.parsedata[index]["name"]);
    String url =
        "https://www.google.com/searchbyimage?site=search&sa=X&image_url=${globals.domain}/image_search/${globals.temp_id}${index}.jpg";
    print(url);
    launchURL(url);
  }

// void _onLongPress(TapPosition position) =>
//     _updateState('long press', position);

  int get_near_object(var objects, double x, double y) {
    double distance = 4294967296;
    double temp;
    int index = 0;
    for (int i = 0; i < objects.length; i++) {
      temp = ((x - ((objects[i]["xmin"] + objects[i]["xmax"])) / 2) *
              (x - ((objects[i]["xmin"] + objects[i]["xmax"])) / 2)) +
          ((y - ((objects[i]["ymin"] + objects[i]["ymax"])) / 2) *
              (y - ((objects[i]["ymin"] + objects[i]["ymax"])) / 2));
      if (temp < distance) {
        distance = temp;
        index = i;
      }
    }
    return index;
  }

  launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceWebView: true, enableJavaScript: true);
    } else {
      throw 'Could not launch $url';
    }
  }

/////////////////ImagePaintPage()
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: PositionedTapDetector2(
          onLongPress: _onLongPress,
          child: (ImagePaintPage()),
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () => speak(),
            tooltip: 'Speak the objects inside the image.',
            child: const Icon(Icons.multitrack_audio)),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          color: Colors.blue,
          child: Container(
            height: 50.0,
          ),
        ),
      ),
    );
  }
}

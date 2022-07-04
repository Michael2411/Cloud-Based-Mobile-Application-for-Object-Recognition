import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:convert';
import 'globals.dart' as globals;
import 'image_paint_page.dart';
import 'positioned_tap_detector_2.dart';
import 'Search_by_long_press.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';

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
    // original image height and width
    double oh = globals.image_data!.height.toDouble();
    double ow = globals.image_data!.width.toDouble();
    // widget height and width
    double wh = ((MediaQuery.of(context).size.height) - 50);
    double ww = MediaQuery.of(context).size.width;
    double diff_height = wh - oh;
    double diff_width = ww - ow;
    //Position data parsing
    var temp = position.global.toString();
    var parse = temp.split('(');
    parse = parse[1].split(',');
    double x = double.parse(parse[0]);
    parse = parse[1].split(')');
    double y = double.parse(parse[0]);

    //Image will be fitted vertically 
    if (diff_height < diff_width) {
      double new_h = wh;
      double scale = new_h / oh ;
      double new_w = ow * scale;
      //Mapping touched pixel position to original image position
      x = x - (ww - new_w) / 2;
      x = x / scale;
      y = y / scale;
    }
     //Image will be fitted horizontally 
    else if (diff_height > diff_width) {
      double new_w = ww;
      double scale = new_w / ow ;
      double new_h = oh * scale;
      //Mapping touched pixel position to original image positio
      x = x - (ww - new_w) / 2;
      y = y - (wh - new_h) / 2;
      x = x / scale;
      y = y / scale;
    }
    int index = get_near_object(globals.parsedata, x, y);
    Random random = new Random();
    int randomNumber = random.nextInt(10000);
    //Format URL to use Google search API 
    String url =
        "https://www.google.com/searchbyimage?site=search&sa=X&image_url=${globals.domain}/image_search/${globals.temp_id}${index}.jpg?rand=${randomNumber}";

    launchURL(url);
  }
  //Get neareast object to the the touched position
  int get_near_object(var objects, double x, double y) {
    double distance = 4294967296;
    double temp;
    double temp_x, temp_y;
    int index = 0;
    for (int i = 0; i < objects.length; i++) {
      temp_x = (objects[i]["xmin"] + objects[i]["xmax"]) / 2;
      temp_y = (objects[i]["ymin"] + objects[i]["ymax"]) / 2;
      temp = ((x - temp_x) * (x - temp_x)) + ((y - temp_y) * (y - temp_y));
      if (temp < distance) {
        distance = temp;
        index = i;
      }
    }
    return index;
  }
  //Open the URL in a new window inside the application to access Google search API 
  launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceWebView: true, enableJavaScript: true);
    } else {
      throw 'Could not launch $url';
    }
  }

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

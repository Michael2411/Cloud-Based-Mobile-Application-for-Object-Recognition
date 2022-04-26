import 'package:flutter/material.dart';
import 'positioned_tap_detector_2.dart';
//import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';

void _onLongPress(TapPosition position) {
  var objects = [
    {
      "xmin": 13.4,
      "ymin": 26,
      "xmax": 577.4783935547,
      "ymax": 971.469543457,
      "confidence": 0.5053740144,
      "class": 15,
      "name": "cat"
    },
    {
      "xmin": 14.6,
      "ymin": 587.4,
      "xmax": 584.1717529297,
      "ymax": 314.2608642578,
      "confidence": 0.3363454342,
      "class": 75,
      "name": "vase"
    }
  ];

  var objects2 = {'image_array': objects, 'google_api_name': "name"};
  var temp = position.relative.toString();
  var parse = temp.split('(');
  parse = parse[1].split(',');
  double x = double.parse(parse[0]);
  parse = parse[1].split(')');
  double y = double.parse(parse[0]);
  int index = get_near_object(objects2["image_array"], x, y);
  print(index);
  String url = 'https://www.google.com/';
  // open_url(url);

  print('onneeeeeeeeeeeeeeeeeeeee');
  launchURL(url);
  print('twwoooooooooooooooooooooo');

  // WebView(
  //   initialUrl: url,
  //   javascriptMode: JavascriptMode.unrestricted,
  // );
  //String url =
  // "https://www.google.com/searchbyimage?site=search&sa=X&image_url={domain}/image_search/${objects2["google_api_name"]}${objects2["image_array"][index]["xmin"]}${objects2["image_array"][index]["ymin"]}${objects2["image_array"][index]["xmax"]}${objects2["image_array"][index]["ymax"]}.jpg";
}

// void _onLongPress(TapPosition position) =>
//     _updateState('long press', position);

int get_near_object(var objects, double x, double y) {
  double distance = 4294967296;
  double temp;
  int index = 0;
  for (int i = 0; i < objects.length; i++) {
    temp = ((x - objects[i]["xmin"]) * (x - objects[i]["xmin"])) +
        ((y - objects[i]["ymin"]) * (y - objects[i]["ymin"]));
    if (temp < distance) {
      distance = temp;
      index = i;
    }
  }
  return index;
}

launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url, forceWebView: true);
  } else {
    throw 'Could not launch $url';
  }
}

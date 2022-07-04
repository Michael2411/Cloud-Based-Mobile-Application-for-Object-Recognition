import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:graduation_app/UIassets/constants.dart';
import 'dart:async';
import 'globals.dart' as globals;

//Class for the page showing the image received by the server and draw the boxes
class ImagePaintPage extends StatefulWidget {
  ImagePaintPage({
    Key? key,
    this.child,
  }) : super(key: key);
  final Widget? child;
  @override
  _ImagePaintPageState createState() => _ImagePaintPageState();
}

//Set the state of the page
class _ImagePaintPageState extends State<ImagePaintPage> {
  ui.Image? image;
  MediaQueryData? queryData;

  @override
  void initState() {
    super.initState();

    loadImage('assets/mainpage.png');
  }

  //Load function that loads an image to initialize the state of the page
  Future loadImage(String path) async {
    final data = await rootBundle.load(path);
    final bytes = data.buffer.asUint8List();
    final image = await decodeImageFromList(bytes);

    setState(() => this.image = image);
  }

  //The main widget of the page
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: themeColor,
          body: Center(
        child: image == null
            ? CircularProgressIndicator()
            : Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: FittedBox(
                  child: SizedBox(
                    width: globals.image_data!.width.toDouble(),
                    height: globals.image_data!.height.toDouble(),
                    child: CustomPaint(
                      painter: ImagePainter(globals.image_data!),
                      child: CustomPaint(
                        painter: RectanglePainter(),
                      ),
                    ),
                  ),
                ),
              ),
      ));
}

//Class inherted from CustomPainter and responsible for drawing the image 
class ImagePainter extends CustomPainter {
  final ui.Image image;

  const ImagePainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    canvas.drawImage(image, Offset.zero, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

//Class inherted from CustomPainter and responsible for objects' rectangles
class RectanglePainter extends CustomPainter {
  var parsedata; // parsedata is the variable to store the json data received from the sever.
  // paint rectangles and object names on the image.
  @override
  void paint(Canvas canvas, Size size) {
    parsedata = globals.parsedata;
    final _random = Random(75); 
    //The seed in random forces the colors to be in a specific order which prevents color flickering
    double fontSize = 0.015 * (size.width + size.height);

    //itterate over each object of the json to draw the rectangles on the image
    for (var dict in parsedata) {
      final a = Offset(dict['xmin'], dict['ymin']);
      final b = Offset(dict['xmax'], dict['ymax']);
      final rect = Rect.fromPoints(a, b);

      // Create color randomly
      Color predectionColor = Color.fromARGB(255, _random.nextInt(200),
          _random.nextInt(200), _random.nextInt(200));

      // Set paint style
      final paint = Paint()
        ..color = predectionColor
        ..strokeWidth = 0.003 * (size.width + size.height)
        ..style = PaintingStyle.stroke;

      canvas.drawRect(rect, paint);

      //Add name of the predicted object over it's square in the image
      TextSpan span = new TextSpan(
          style: new TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontSize: fontSize,
              backgroundColor: predectionColor,
              fontFamily: 'Roboto'),
          text: " " + dict['name'] + " ");
      TextPainter tp = new TextPainter(
          text: span,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center);
      tp.layout();
      tp.paint(
          canvas,
          // ignore: unnecessary_new
          new Offset(dict['xmin'],
              dict['ymin'] - fontSize - 5));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

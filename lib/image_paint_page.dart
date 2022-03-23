import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'dart:async';
import 'globals.dart' as globals;

class ImagePaintPage extends StatefulWidget {
  @override
  _ImagePaintPageState createState() => _ImagePaintPageState();
}


class _ImagePaintPageState extends State<ImagePaintPage> {  
  ui.Image? image;
  MediaQueryData? queryData;

  //Need to replace the image with the image captured by camera
  @override
  void initState() {
    super.initState();

    loadImage('assets/image.jpg');
  }

  Future loadImage(String path) async {
    final data = await rootBundle.load(path);
    final bytes = data.buffer.asUint8List();
    final image = await decodeImageFromList(bytes);
    

    setState(() => this.image = image);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child:
              image == null
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
                        )
                        ,
                      ),
                    ),
                  
                  ),
                ),
            
          )        
      );
}


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


class RectanglePainter extends CustomPainter {
  //parsed data, Function needs to update this variable by the cloud data
  var parsedata;
  
  
  @override
  void paint(Canvas canvas, Size size) {
    parsedata = globals.parsedata;
    print(globals.parsedata);
    final _random = Random();
    final widthRatio = 1  /*(size.width*2 Variable for the width of the image sent to cloud*/;
    final heightRatio = 1 /*/(size.height*2 Variable for the height of the image sent to cloud*/;
    double fontSize = 30;

    //We need to change the magic numbers of the cloud image size
    for(var dict in parsedata){
      final a = Offset(dict['xmin']*widthRatio,
                       dict['ymin']*heightRatio);
      final b = Offset(dict['xmax']*widthRatio,
                       dict['ymax']*heightRatio);
      final rect = Rect.fromPoints(a, b);

      Color predectionColor = Color.fromARGB(
            255, 
            _random.nextInt(256),
            _random.nextInt(256), 
            _random.nextInt(256)
        );

      final paint = Paint()
        ..color = predectionColor
        ..strokeWidth = 0.003*(size.width + size.height)
        ..style = PaintingStyle.stroke;
      
      canvas.drawRect(rect, paint);
      

      //Add name of the predicted object over it's square in the image
      TextSpan span = new TextSpan(
          style: new TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: fontSize, backgroundColor: predectionColor,
              fontFamily: 'Roboto'), text: " "+ dict['name'] + " ");
      TextPainter tp = new TextPainter(
          text: span, textDirection: TextDirection.ltr, textAlign: TextAlign.center);
      tp.layout();
      tp.paint(canvas, new Offset(dict['xmin']*widthRatio, dict['ymin']*heightRatio - fontSize - 5));
    }
  }


  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

}
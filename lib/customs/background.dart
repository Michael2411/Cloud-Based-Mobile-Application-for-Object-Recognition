

import 'package:flutter/cupertino.dart';

import '../UIassets/constants.dart';

class BACKGROUND extends StatelessWidget {
  final double width, height;

  const BACKGROUND(
      { required this.width, required this.height}) ;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(
          image:DecorationImage(
                image: AssetImage("assets/college.jpg"),
                fit:BoxFit.cover,
        ),
        ),
       );
  }
}
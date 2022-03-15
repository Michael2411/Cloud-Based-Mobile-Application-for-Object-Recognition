import 'dart:io';
import 'navigation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
      routes:<String, WidgetBuilder>{
        '/home': (context) => HomePage()
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  File? image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Picking Image'),
        ),
        body: Center(
          child: Column(
            children: [
              image != null ? Image.file(image!) : const SizedBox(),
              ElevatedButton(
                  onPressed: imagePick, child: const Text('Pick an image')),
              ElevatedButton(onPressed:(){
                Navigator.pushNamed(context,'/home');
              }, child: const Text('Go Back')),
            ],
          ),
        ));
  }

  void imagePick() async {
    final ImagePicker _picker = ImagePicker();
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage == null) {
      return;
    }
    setState(() {
      image = File(pickedImage.path);
    });

  }
}


import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'globals.dart' as globals;
import 'dart:convert';



Future<void> main() async {
  runApp(GetCloud());
}

class GetCloud extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return MyAppstate1();
  }
}



class MyAppstate1 extends State<GetCloud> {
  List<dynamic> urlimages=[];

  get_image_list() async {
  print("gggggggggggg");
  var request =http.MultipartRequest("POST", Uri.parse("${globals.domain}/api/get_cloud"));
  request.fields['client_id'] =globals.temp_id ;
  http.Response response =await http.Response.fromStream(await request.send());
  var parsed = json.decode(response.body);
  setState(() {
    urlimages=parsed['images_url'];
  });
  print(parsed['images_url']);

  }

  





@override
Widget build(BuildContext context) {
  if (globals.count1){
    get_image_list(); 
    globals.count1=false;
  } else{
    globals.count1=true;
  }
  
  return Container(
    
    child: PhotoViewGallery.builder(
      scrollPhysics: const BouncingScrollPhysics(),
      builder: (BuildContext context, int index) {
        print(index);
        return PhotoViewGalleryPageOptions(
          imageProvider: NetworkImage(urlimages[index]),
          initialScale: PhotoViewComputedScale.contained * 1,
          heroAttributes: PhotoViewHeroAttributes(tag: index),
        );
      },
      itemCount: urlimages.length,
      loadingBuilder: (context, event) => Center(
        child: Container(
          width: 20.0,
          height: 20.0,
          child: CircularProgressIndicator(
            value: 0.8,
            valueColor: new AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 39, 98, 176)),
          ),
        ),
      ),
    )
  );
}

}

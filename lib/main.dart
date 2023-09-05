import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:imagetoai/conver.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MaterialApp(
      home: HomePage(),
    ),
  );
}

enum AppState {
  free,
  picked,
  cropped,
}

String? url;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late AppState state;
  File? imageFile;
  String? imagename;
  UploadTask? uploadTask;

  Future uploadFile() async {
    final path = 'image/$imagename';
    final file = File(imageFile!.path);

    final ref = FirebaseStorage.instance.ref().child(path);
    uploadTask = ref.putFile(file);

    final snapshot = await uploadTask!.whenComplete(() => null);
    url = await snapshot.ref.getDownloadURL();
    print('Download Link $url');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    state = AppState.free;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          InkWell(
              onTap: () {
                if (url != null) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConverPage(),
                      ));
                }
              },
              child: Icon(Icons.arrow_circle_right))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (state == AppState.free) {
            _pickImage();
          } else if (state == AppState.picked) {
            _cropImage();
          } else if (state == AppState.cropped) {
            _clearImage();
          }
        },
        child: _buildButtonIcon(),
      ),
      body: Center(
        child: imageFile != null ? Image.file(imageFile!) : Text(""),
      ),
    );
  }

  Widget _buildButtonIcon() {
    if (state == AppState.free) {
      return Icon(Icons.add);
    } else if (state == AppState.picked) {
      return Icon(Icons.crop);
    } else if (state == AppState.cropped) {
      return Icon(Icons.clear);
    } else {
      return Container();
    }
  }

  _pickImage() async {
    final pickImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    imageFile = pickImage != null ? File(pickImage!.path) : null;
    imagename = pickImage!.name;
    if (imageFile != null) {
      state = AppState.picked;
      setState(() {});
      print(state);
    }
  }

  _cropImage() async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile!.path,
      aspectRatioPresets: Platform.isAndroid
          ? [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9
            ]
          : [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio5x3,
              CropAspectRatioPreset.ratio5x4,
              CropAspectRatioPreset.ratio7x5,
              CropAspectRatioPreset.ratio16x9
            ],
      uiSettings: [
        AndroidUiSettings(
          toolbarColor: Colors.deepOrange,
          toolbarTitle: 'Cropper',
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: 'cropper')
      ],
    );
    if (croppedFile != null) {
      imageFile = File(croppedFile.path);
      print(croppedFile.path);
      state = AppState.cropped;
      setState(() {});
    }
    await uploadFile();
  }

  _clearImage() async {
    imagename = null;
    imageFile = null;
    url = null;
    setState(() {
      state = AppState.free;
    });
  }
}

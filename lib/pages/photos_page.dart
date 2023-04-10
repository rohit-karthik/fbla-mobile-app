import 'dart:io';
import 'package:fbla_app_22/classes/photo_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import "package:flutter/material.dart";
import "package:photo_view/photo_view.dart";
import "package:responsive_grid_list/responsive_grid_list.dart";
import "package:image_picker/image_picker.dart";

class PhotosPage extends StatefulWidget {
  const PhotosPage({Key? key}) : super(key: key);

  @override
  State<PhotosPage> createState() => _PhotosPageState();
}

class _PhotosPageState extends State<PhotosPage> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  final List<String> _imagesList = <String>[];

  String textToShow = "Awaiting photos...";

  void addImages() {
    _imagesList.removeRange(0, _imagesList.length);

    db.collection("photos").get().then(
      (value) {
        for (var doc in value.docs) {
          setState(() {
            _imagesList.add(doc["downloadUrl"]);
          });
        }

        if (_imagesList.isNotEmpty) {
          setState(() {
            textToShow = "No photos shared yet!";
          });
        }
      },
    );
  }

  @override
  void initState() {
    addImages();
    super.initState();
  }

  void showPhotoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        PhotoChoice? choice = PhotoChoice.camera;
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.secondary,
            ),
          ),
          child: AlertDialog(
            title: const Text('Choose a photo source'),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: const Text('Camera'),
                      leading: Radio<PhotoChoice>(
                        fillColor: MaterialStateColor.resolveWith(
                            (states) => Colors.green[900]!),
                        focusColor: MaterialStateColor.resolveWith(
                            (states) => Colors.green[900]!),
                        value: PhotoChoice.camera,
                        groupValue: choice,
                        onChanged: (PhotoChoice? value) {
                          setState(() {
                            choice = value;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('Gallery'),
                      leading: Radio<PhotoChoice>(
                        fillColor: MaterialStateColor.resolveWith(
                            (states) => Colors.green[900]!),
                        focusColor: MaterialStateColor.resolveWith(
                            (states) => Colors.green[900]!),
                        value: PhotoChoice.gallery,
                        groupValue: choice,
                        onChanged: (PhotoChoice? value) {
                          setState(() {
                            choice = value;
                          });
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: const Text('OK'),
                onPressed: () async {
                  if (choice == PhotoChoice.gallery) {
                    _getFromGallery();
                  } else {
                    _getFromCamera();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  _getFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    try {
      storage
          .ref("photos/${pickedFile!.name}")
          .putFile(
            File(pickedFile.path),
          )
          .then(
        (res) {
          res.ref.getDownloadURL().then(
            (value) {
              db.collection("photos").add({
                "downloadUrl": value,
              });
            },
          );
        },
      );
    } catch (e) {
      throw Exception(e);
    }
  }

  _getFromCamera() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );

    try {
      storage
          .ref("photos/${pickedFile!.name}")
          .putFile(
            File(pickedFile.path),
          )
          .then(
        (res) {
          res.ref.getDownloadURL().then(
            (value) {
              db.collection("photos").add({
                "downloadUrl": value,
              });
            },
          );
        },
      );
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_imagesList.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text("Photos"),
          actions: [
            IconButton(
              onPressed: () {
                addImages();
              },
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(10),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  "Photo Share:",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ResponsiveGridList(
                minItemWidth: MediaQuery.of(context).size.width / 3,
                children: [
                  for (String image in _imagesList)
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              child: Stack(
                                children: [
                                  PhotoView(
                                    imageProvider: NetworkImage(image),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    color: Colors.white,
                                    icon: const Icon(Icons.close),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Image.network(
                          image,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showPhotoDialog();
          },
          child: const Icon(Icons.add),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text("Photos"),
          actions: [
            IconButton(
              onPressed: () {
                addImages();
              },
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: Center(
          child: Text(
            textToShow,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showPhotoDialog();
          },
          child: const Icon(Icons.add),
        ),
      );
    }
  }
}

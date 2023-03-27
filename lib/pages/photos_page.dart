import 'dart:ffi';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import "package:flutter/material.dart";
import "package:photo_view/photo_view.dart";
import "package:responsive_grid_list/responsive_grid_list.dart";
import "package:image_picker/image_picker.dart";

class PhotosPage extends StatefulWidget {
  PhotosPage({Key? key}) : super(key: key);

  @override
  State<PhotosPage> createState() => _PhotosPageState();
}

class _PhotosPageState extends State<PhotosPage> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  final List<String> _imagesList = <String>[];
  final ImagePicker _picker = ImagePicker();

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
            _getFromCamera();
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
            _getFromCamera();
          },
          child: const Icon(Icons.add),
        ),
      );
    }
  }
}

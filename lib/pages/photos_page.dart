import 'dart:io';
import 'package:fbla_app_22/classes/photo_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fbla_app_22/global_vars.dart';
import 'package:firebase_storage/firebase_storage.dart';
import "package:flutter/material.dart";
import "package:photo_view/photo_view.dart";
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
  final List<Map<String, String>> _toApprove = <Map<String, String>>[];

  String textToShow = "Awaiting photos...";

  // This function likely images to a project to the database
  void addImages() {
    _imagesList.removeRange(0, _imagesList.length);
    _toApprove.removeRange(0, _toApprove.length);

    db.collection("photos").get().then(
      (value) {
        for (var doc in value.docs) {
          // This function adds a new element (a download URL) to the `_imagesList` list using the `.add()` method, and updates the state of the application using `setState()`.
          if (emailType == "admin") {
            if (!doc["approved"]) {
              Map<String, String> toAdd = {
                "downloadUrl": doc["downloadUrl"],
                "id": doc.id,
              };

              _toApprove.add(toAdd);
            } else {
              setState(() {
                _imagesList.add(doc["downloadUrl"]);
              });
            }
          } else if (doc["approved"]) {
            setState(() {
              _imagesList.add(doc["downloadUrl"]);
            });
          }
        }

        if (_imagesList.isNotEmpty) {
          // This function updates the state of the textToShow variable to the value "No photos shared yet!" using the setState method, which triggers a new build of the user interface with the updated value.
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

  // This function uploads an image to the Firebase Storage bucket and adds a reference to the image to the database.
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
                            (states) => const Color(0xFF183153)),
                        focusColor: MaterialStateColor.resolveWith(
                            (states) => const Color(0xFF183153)),
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
                            (states) => const Color(0xFF183153)),
                        focusColor: MaterialStateColor.resolveWith(
                            (states) => const Color(0xFF183153)),
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
                    await _getFromGallery();
                  } else {
                    await _getFromCamera();
                  }
                  if (!mounted) return;
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // This function grabs a photo from the phone gallery and uploads it to Firebase storage.
  _getFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    bool approved = false;

    if (emailType == "admin") {
      approved = true;
    }

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
                "approved": approved,
              });
            },
          );
          addImages();
          setState(() {});
        },
      );
    } catch (e) {
      throw Exception(e);
    }
  }

  // This function snaps a picture from the camera and uploads it to Firebase storage.
  _getFromCamera() async {
    // Pick a photo from the camera
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );

    bool approved = false;

    if (emailType == "admin") {
      approved = true;
    }

    try {
      // Add the photo to the storage
      storage
          .ref("photos/${pickedFile!.name}")
          .putFile(
            File(pickedFile.path),
          )
          .then(
        (res) {
          // Then add it to the database for a
          // reference
          res.ref.getDownloadURL().then(
            (value) {
              db.collection("photos").add({
                "downloadUrl": value,
                "approved": approved,
              });
            },
          );
          addImages();
          setState(() {});
        },
      );
    } catch (e) {
      throw Exception(e);
    }
  }

  // This function displays all the photos the school community has uploaded.
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
        body: ListView(
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
            // Show text highlighting approved images if admin
            if (emailType == "admin")
              const Padding(
                padding: EdgeInsets.all(10),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    "Approved images:",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 20.0,
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
            if (emailType == "admin")
              const Padding(
                padding: EdgeInsets.all(10),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    "To approve:",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            if (emailType == "admin")
              GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                shrinkWrap: true,
                mainAxisSpacing: 20.0,
                children: [
                  for (Map image in _toApprove)
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
                                    imageProvider:
                                        NetworkImage(image["downloadUrl"]),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    color: Colors.white,
                                    icon: const Icon(Icons.close),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Padding(
                                      padding: const EdgeInsets.all(25.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              db
                                                  .collection("photos")
                                                  .doc(image["id"])
                                                  .update(
                                                {
                                                  "approved": true,
                                                },
                                              );

                                              Navigator.pop(context);

                                              addImages();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.green.shade900,
                                            ),
                                            child: const Row(
                                              children: [
                                                Icon(Icons.check),
                                                Text("Approve"),
                                              ],
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              // Delete the image from firebase
                                              storage
                                                  .refFromURL(
                                                      image["downloadUrl"])
                                                  .delete();

                                              // Also delete from db
                                              db
                                                  .collection("photos")
                                                  .doc(image["id"])
                                                  .delete();

                                              Navigator.pop(context);

                                              addImages();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.red.shade900,
                                            ),
                                            child: const Row(
                                              children: [
                                                Icon(Icons.close),
                                                Text("Reject"),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                        child: Image.network(
                          image["downloadUrl"],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                ],
              ),
            // Padding
            const SizedBox(
              height: 50,
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

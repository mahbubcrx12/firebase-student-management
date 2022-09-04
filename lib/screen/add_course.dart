import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

class AddCourse extends StatefulWidget {
  const AddCourse({super.key});

  @override
  State<AddCourse> createState() => _AddCourseState();
}

class _AddCourseState extends State<AddCourse> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _feeController = TextEditingController();

  XFile? _courseImage;
  _takeImage() async {
    ImagePicker _pickImage = ImagePicker();
    _courseImage = await _pickImage.pickImage(source: ImageSource.camera);
    setState(() {});
  }

  String? _imgURL;
  _dataWrite() async {
    File _imageFile = File(_courseImage!.path);

    FirebaseStorage _storage = FirebaseStorage.instance;
    UploadTask _uploadTask =
        _storage.ref("courses").child(_courseImage!.name).putFile(_imageFile);

    TaskSnapshot snapshot = await _uploadTask;
    _imgURL = await snapshot.ref.getDownloadURL();

    CollectionReference _course =
        FirebaseFirestore.instance.collection("courses");

    _course.add({
      "course_name": _nameController.text,
      "course_fee": _feeController.text,
      "image": _imgURL
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 600,
      decoration: BoxDecoration(
        color: Colors.white54,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                  //height: 300,
                  child: _courseImage == null
                      ? InkWell(
                          onTap: () {
                            _takeImage();
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                                "https://upload.wikimedia.org/wikipedia/commons/thumb/a/aa/Camera_Icon.jpg/480px-Camera_Icon.jpg"),
                          ),
                        )
                      : Image.file(
                          File(_courseImage!.path),
                        )),
            ),
            Text("Take an Image"),
            SizedBox(
              height: 15,
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: "Enter Course Name",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
            SizedBox(
              height: 12,
            ),
            TextField(
              controller: _feeController,
              decoration: InputDecoration(
                hintText: "Enter Course Fee",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
            SizedBox(
              height: 12,
            ),
            ElevatedButton(
                onPressed: () {
                  _dataWrite();
                  Navigator.of(context).pop();
                },
                child: Text("Submit Data"))
          ],
        ),
      ),
    );
  }
}

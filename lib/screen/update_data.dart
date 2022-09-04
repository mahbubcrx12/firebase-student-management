import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
class UpdateData extends StatefulWidget {
  String? documentId;
  String? courseName;
  String? CourseFee;
  String? courseImg;
  UpdateData(
      this.documentId, this.courseName, this.CourseFee, this.courseImg);

  @override
  State<UpdateData> createState() => _UpdateDataState();
}

class _UpdateDataState extends State<UpdateData> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _feeController = TextEditingController();

  XFile? _courseImage;
  takeImage() async {
    ImagePicker _pickImage = ImagePicker();
    _courseImage = await _pickImage.pickImage(source: ImageSource.camera);
    setState(() {});
  }
  String? imageURL;
  writeUpdateData(selectedDocument) async{
    if(_courseImage==null){
      CollectionReference _courseData=FirebaseFirestore.instance.collection("courses");
      _courseData.doc(selectedDocument).update({
        "course_name":_nameController.text,
        "course_fee":_feeController.text,
        "image":widget.courseImg
      });
    }
    else{
      File imageFile=File(_courseImage!.path);

      FirebaseStorage _storage=FirebaseStorage.instance;
      UploadTask _uploadTask=_storage.ref("courses").child(_courseImage!.name).putFile(imageFile);

      TaskSnapshot snapshot=await _uploadTask;
      imageURL=await snapshot.ref.getDownloadURL();

      CollectionReference _courseData=FirebaseFirestore.instance.collection("courses");
      _courseData.add({
        "course_name": _nameController.text,
        "course_fee": _feeController.text,
        "image": imageURL
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _nameController.text=widget.courseName!;
    _feeController.text=widget.CourseFee!;
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

                  child: _courseImage == null
                      ? Stack(
                    children: [
                      Image.network('${widget.courseImg}'),
                      Positioned(
                          right: 50,
                          left: 50,
                          bottom: 30,
                          child: IconButton(
                            icon: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(Icons.camera,size: 50,color: Colors.red,),
                            ),
                            onPressed: () {
                              takeImage();
                            },
                          ))
                    ],
                    
                  )
                      : Image.file(File(_courseImage!.path))
                  ),
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
                  writeUpdateData(widget.documentId);
                  Navigator.of(context).pop();
                },
                child: Text("Update"))
          ],
        ),
      ),

    );
  }
}

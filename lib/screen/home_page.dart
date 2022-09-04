import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_std_mngmnt/screen/add_course.dart';
import 'package:firebase_std_mngmnt/screen/update_data.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Stream<QuerySnapshot> _courseStream =
      FirebaseFirestore.instance.collection('courses').snapshots();

  addNewCourse() {
    return showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        isDismissible: true,
        builder: (context) => AddCourse());
  }

  Future<void> deleteCourse(documentId) {
    return FirebaseFirestore.instance
        .collection("courses")
        .doc(documentId)
        .delete()
        .then((value) => print("Data deleted"))
        .catchError((e) => print(e));
  }
  updateData(selectedDocument,courseName,courseFee,courseImg){
    return showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        isDismissible: true,
        builder: (context) => UpdateData(selectedDocument,courseName,courseFee,courseImg));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        title: Text("Student Management System"),
        centerTitle: true,
        backgroundColor: Colors.black38,
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 10,
        backgroundColor: Colors.green,
        onPressed: () {
          addNewCourse();
        },
        child: Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _courseStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              return Stack(children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.transparent),
                    height: 120,
                    //width: double.infinity,
                    child: Row(
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * .5,
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                bottomLeft: Radius.circular(20)),
                            child: Image.network(
                              data["image"],
                              fit: BoxFit.cover,
                              //width: MediaQuery.of(context).size.width*.33,
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * .45,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(20),
                                  topRight: Radius.circular(20)),
                              color: Colors.white54),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    child: Text(
                                      data["course_name"],
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 7,
                                  ),
                                  Container(
                                    child: Text(
                                      data["course_fee"],
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Positioned(
                    right: 55,
                    bottom: 10,
                    child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  updateData(document.id, data["course_name"], data["course_fee"], data["image"]);
                                },
                                icon: Icon(
                                  Icons.edit,
                                  color: Colors.black54,
                                )),
                            IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      elevation: 10,
                                      backgroundColor: Colors.white54,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      title: Text('Do you want to delete?'),
                                      actions: [
                                        ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text('Go Back')),
                                        ElevatedButton(
                                            onPressed: () {
                                              deleteCourse(document.id);
                                              Navigator.pop(context);
                                            },
                                            child:
                                                Container(child: Text('Yes')))
                                      ],
                                    ),
                                  );
                                },
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.black54,
                                )),
                          ],
                        )))
              ]);
            }).toList(),
          );
        },
      ),
    );
  }
}

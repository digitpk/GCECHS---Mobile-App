import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:housingsociety/models/user.dart';
import 'package:housingsociety/screens/home/admin/residents.dart';
import 'package:housingsociety/screens/home/modules/profile/editEmail.dart';
import 'package:housingsociety/screens/home/modules/profile/editName.dart';
import 'package:housingsociety/screens/home/modules/profile/editPassword.dart';
import 'package:housingsociety/screens/home/modules/profile/editPhoneNumber.dart';
import 'package:housingsociety/screens/home/modules/profile/editflat.dart';
import 'package:housingsociety/screens/home/modules/profile/reusableprofiletile.dart';
import 'package:housingsociety/services/auth.dart';
import 'package:housingsociety/services/storage.dart';
import 'package:housingsociety/shared/constants.dart';
import 'package:housingsociety/shared/loading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  static const String id = 'profile';
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  File? profileImage;
  final picker = ImagePicker();
  bool loading = false;
  StorageService storage = StorageService();

  Future getImage(ImageSource source, String uid) async {
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 50,
    );

    if (pickedFile != null) {
      String profileImagePath = pickedFile.path;

      // Show any UI to let the user confirm or adjust the image if needed
      // Then upload the image to storage
      await storage.uploadProfilePicture(profileImagePath, uid);

      setState(() {
        profileImage = File(pickedFile.path);
      });
    }
  }

  // Future getImage(source, uid) async {
  //   final pickedFile = await picker.getImage(
  //     source: source,
  //     imageQuality: 50,
  //   );
  //   String profileImagePath;
  //
  //   setState(() {
  //     if (pickedFile != null) {
  //       profileImage = File(pickedFile.path);
  //       profileImagePath = pickedFile.path;
  //       storage.uploadProfilePicture(profileImagePath, uid);
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CurrentUser>(context);
    DocumentReference userProfile =
        FirebaseFirestore.instance.collection('user_profile').doc(user.uid);
    return StreamBuilder<DocumentSnapshot>(
        stream: userProfile.snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Loading();
          }
          return Scaffold(
            appBar: AppBar(
              title: Text('Profile'),
            ),
            body: ListView(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      child: CircleAvatar(
                        radius: 65.0,
                        //backgroundColor: Colors.white,
                        backgroundImage: snapshot.data != null &&
                                snapshot.data!['profile_picture'] != null &&
                                snapshot.data!['profile_picture'] != ''
                            ? NetworkImage(
                                snapshot.data!['profile_picture'] as String)
                            : AssetImage(
                                    'assets/images/default_profile_pic.jpg')
                                as ImageProvider<Object>?,

                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            height: 50,
                            width: 50,
                            child: FloatingActionButton(
                              backgroundColor: kAmaranth,
                              onPressed: () {
                                showModalBottomSheet(
                                  backgroundColor: Colors.transparent,
                                  context: context,
                                  builder: (context) {
                                    return Container(
                                      height: 130,
                                      decoration: BoxDecoration(
                                        color: kSpaceCadet,
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(15),
                                        ),
                                      ),
                                      child: ListView(
                                        children: [
                                          ListTile(
                                            leading: Icon(Icons.camera_alt),
                                            title: Text('Choose from Camera'),
                                            onTap: () {
                                              getImage(ImageSource.camera,
                                                  user.uid!);
                                              Navigator.pop(context);
                                            },
                                          ),
                                          Divider(),
                                          ListTile(
                                            leading: Icon(Icons.collections),
                                            title: Text('Choose from gallery'),
                                            onTap: () {
                                              getImage(ImageSource.gallery,
                                                  user.uid!);
                                              Navigator.pop(context);
                                            },
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Icon(
                                Icons.add_a_photo,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    ReusableProfileTile(
                      label: 'Name',
                      // value: AuthService().userName(),
                      // value: user.name!,
                      value: snapshot.data!['name'],
                      onpress: () {
                        Navigator.pushNamed(context, EditName.id);
                      },
                    ),
                    ReusableProfileTile(
                      label: 'Email',
                      value: user.email!,
                      onpress: () {
                        Navigator.pushNamed(context, EditEmail.id);
                      },
                    ),
                    ReusableProfileTile(
                      label: 'Phone',
                      value: snapshot.data!['phone_no'],
                      onpress: () {
                        Navigator.pushNamed(context, EditPhoneNumber.id);
                      },
                    ),
                    ReusableProfileTile(
                      label: 'Change password',
                      value: ' ',
                      onpress: () {
                        Navigator.pushNamed(context, EditPassword.id);
                      },
                    ),
                    ReusableProfileTile(
                      label: 'Flat no',
                      value: snapshot.data!['wing'] +
                          '  ' +
                          snapshot.data!['flatno'],
                      onpress: () {
                        Navigator.pushNamed(context, EditFlat.id);
                      },
                    ),
                    Visibility(
                      visible: snapshot.data!['userType'] == 'admin',
                      child: ReusableProfileTile(
                        label: 'Manage Residents',
                        value: '',
                        onpress: () {
                          Navigator.pushNamed(context, Residents.id);
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor: kOxfordBlue,
                                      content: Text(
                                        'Are you sure you want\nto delete your account?\nThis action is irreversible.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      actions: [
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text(
                                                    'No',
                                                    style: TextStyle(
                                                        color: kAmaranth),
                                                  )),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  primary: kAmaranth,
                                                ),
                                                onPressed: () {
                                                  AuthService().delteAccount();
                                                },
                                                child: Center(
                                                  child: Text('Delete'),
                                                ),
                                              ),
                                            ]),
                                      ],
                                    );
                                  });
                            },
                            child: Text(
                              'Delete account',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }
}

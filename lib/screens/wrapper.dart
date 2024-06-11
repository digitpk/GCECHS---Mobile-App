import 'package:flutter/material.dart';
import 'package:housingsociety/models/user.dart';
import 'package:housingsociety/screens/authenticate/authenticate.dart';
import 'package:housingsociety/screens/home/home.dart';
import 'package:provider/provider.dart';

// class Wrapper extends StatefulWidget {
//   @override
//   _WrapperState createState() => _WrapperState();
// }
//
// class _WrapperState extends State<Wrapper> {
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final user = Provider.of<CurrentUser>(context);
//     return user == null ? Authenticate() : Home();
//   }
// }

class Wrapper extends StatefulWidget {
  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CurrentUser>(context);
    // Check if the user is authenticated
    if (user.uid == null) {
      setState(() {});
      return Authenticate();
      // User is not authenticated, navigate to the login screen
    } else {
      setState(() {});
      return Home();
      // return Authenticate();
      // User is authenticated, navigate to the home screen
    }
  }
}

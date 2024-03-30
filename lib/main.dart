import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:housingsociety/firebase_options.dart';
import 'package:housingsociety/models/user.dart';
import 'package:housingsociety/screens/wrapper.dart';
import 'package:housingsociety/services/auth.dart';
import 'package:provider/provider.dart';

import 'routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<CurrentUser>.value(
      initialData:
          CurrentUser(uid: null, email: null, name: null, profilePicture: null),
      value: AuthService()
          .user, // Make sure AuthService().user returns Stream<CurrentUser>
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          primaryColor: Color(0xFF0A0E21),
          scaffoldBackgroundColor: Color(0xFF0A0E21),
        ),
        home: Wrapper(), // Ensure Wrapper handles user authentication
        routes: routes, // Define your routes
      ),
    );
  }
}

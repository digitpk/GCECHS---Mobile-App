import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:housingsociety/models/user.dart';
import 'package:housingsociety/screens/home/home.dart';
import 'package:housingsociety/services/database.dart';

import '../screens/authenticate/authenticate.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseService db = DatabaseService();

  // CurrentUser _userFromFireBase(User user) {
  //   return user != null
  //       ? CurrentUser(
  //       uid: user.uid,
  //       email: user.email,
  //       name: user.displayName,
  //       profilePicture: user.photoURL)
  //       : null;
  // }

  CurrentUser _userFromFireBase(User? user) {
    if (user != null) {
      return CurrentUser(
        uid: user.uid,
        email: user.email,
        name: user.displayName ?? '',
        // Provide a default value for name if null
        profilePicture: user.photoURL ?? '',
        // Provide a default value for profilePicture if null
      );
    } else {
      Get.offAll(() => Authenticate());
      throw Exception(
          "User is not authenticated"); // Throw an exception for null user
    }
  }

  Stream<CurrentUser> get user {
    return _auth.userChanges().map((user) {
      try {
        if (user != null) {
          return _userFromFireBase(user);
          // Return non-nullable CurrentUser object
        } else {
          Get.offAll(() => Authenticate());
          throw Exception("User is not authenticated");
        }
      } catch (e) {
        print("Error: $e");
        // Handle the exception by returning a default user object or null
        return CurrentUser(uid: '', email: '', name: '', profilePicture: '');
      }
    });
  }

  // Stream<CurrentUser> get user {
  //   return _auth.userChanges().map(_userFromFireBase);
  // }

  Future createUserWithEmailAndPassword(String email, String password,
      String name, String wing, String flatno) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      userCredential.user!.updateProfile(displayName: name).then((_) {
        User user = _auth.currentUser!;
        user.reload();
        User updateduser = _auth.currentUser!;
        print(updateduser.displayName);
        db.setProfileonRegistration(user.uid, name, wing, flatno);
        return _userFromFireBase(updateduser);
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        return null;
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future logInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User user = userCredential.user!;
      Get.offAll(() => Home());
      return _userFromFireBase(user);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        return null;
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  String userName() {
    if (_auth.currentUser != null) {
      final User user = _auth.currentUser!;
      return user.displayName!;
    } else {
      return '';
    }
  }

  String userId() {
    if (_auth.currentUser != null) {
      final User user = _auth.currentUser!;
      return user.uid;
    } else {
      return '';
    }
  }

  Future signOut() async {
    await _auth.signOut().then((value) {
      Get.offAll(() => Authenticate());
    });
    return null;
  }

  Future updateDisplayName(updatedName) async {
    _auth.currentUser!
        .updateProfile(
      displayName: updatedName,
    )
        .then((_) {
      User user = _auth.currentUser!;
      user.reload();
      User updateduser = _auth.currentUser!;
      return _userFromFireBase(updateduser);
    });
    return userName();
  }

  Future updateProfilePicture(updatedProfilePicture) async {
    _auth.currentUser!.updatePhotoURL(
      updatedProfilePicture,
    );
    return _userFromFireBase(_auth.currentUser);
  }

  Future updateEmail(email, password) async {
    try {
      // Create a credential object for reauthentication
      AuthCredential credential = EmailAuthProvider.credential(
        email: _auth.currentUser!.email!,
        password: password,
      );

      // Reauthenticate the current user with the provided credential
      await _auth.currentUser!.reauthenticateWithCredential(credential);

      // Update the email address of the current user
      await _auth.currentUser!.updateEmail(email);

      // Return a success message if the email is updated successfully
      return 'Email updated successfully';
    } on FirebaseAuthException catch (e) {
      // Handle FirebaseAuthException errors
      if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided.';
      } else {
        // Handle other FirebaseAuthException errors
        print('FirebaseAuthException: ${e.message}');
        return 'An error occurred. Please try again.';
      }
    } catch (e) {
      // Handle generic errors
      print('Error: $e');
      return 'An error occurred. Please try again.';
    }
  }

  // Future updateEmail(email, password) async {
  //   try {
  //     EmailAuthCredential credential = EmailAuthProvider.credential(
  //         email: _auth.currentUser.email, password: password);
  //     await _auth.currentUser.reauthenticateWithCredential(credential);
  //     await _auth.currentUser.updateEmail(email);
  //     EmailAuthCredential newCredential = EmailAuthProvider.credential(
  //       email: email,
  //       password: password,
  //     );
  //     await _auth.currentUser.reauthenticateWithCredential(newCredential);
  //     return 'Email updated successfully';
  //   } on FirebaseAuthException catch (e) {
  //     if (e.code == 'email-already-in-use')
  //       return 'The account already exists for that email.';
  //     if (e.code == 'wrong-password') return 'Wrong password provided.';
  //   } catch (e) {
  //     print(e);
  //     return 'An error occurred.Please try again.';
  //   }
  // }

  Future updatePassword(oldPassword, newPassword) async {
    try {
      // Create a credential object for reauthentication with old password
      AuthCredential credential = EmailAuthProvider.credential(
        email: _auth.currentUser!.email!,
        password: oldPassword,
      );

      // Reauthenticate the current user with the provided credential
      await _auth.currentUser!.reauthenticateWithCredential(credential);

      // Update the password of the current user
      await _auth.currentUser!.updatePassword(newPassword);

      // Return a success message if the password is updated successfully
      return 'Password updated successfully';
    } on FirebaseAuthException catch (e) {
      // Handle FirebaseAuthException errors
      if (e.code == 'wrong-password') {
        return 'Wrong password provided.';
      } else {
        // Handle other FirebaseAuthException errors
        print('FirebaseAuthException: ${e.message}');
        return 'An error occurred. Please try again.';
      }
    } catch (e) {
      // Handle generic errors
      print('Error: $e');
      return 'An error occurred. Please try again.';
    }
  }

  // Future updatePassword(oldPassword, newPassword) async {
  //   try {
  //     AuthCredential credential = EmailAuthProvider.credential(
  //       email: _auth.currentUser!.email!,
  //       password: oldPassword,
  //     );
  //     await _auth.currentUser!.reauthenticateWithCredential(credential);
  //     await _auth.currentUser!.updatePassword(newPassword);
  //     AuthCredential newCredential = EmailAuthProvider.credential(
  //       email: _auth.currentUser!.email!,
  //       password: newPassword,
  //     );
  //     await _auth.currentUser!.reauthenticateWithCredential(newCredential);
  //     return 'Password updated successfully';
  //   } on FirebaseAuthException catch (e) {
  //     if (e.code == 'wrong-password') {
  //       return 'Wrong password provided.';
  //     }
  //   }
  // }

  Future delteAccount() {
    _auth.signOut();
    return _auth.currentUser!.delete();
  }
}

import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthAPI {
  static final FirebaseAuth auth = FirebaseAuth.instance;

  FirebaseAuthAPI() {
    auth.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });
  }

  Stream<User?> getUser() {
    return auth.authStateChanges();
  }

  Future<String?> signIn(String email, String password) async {
    // UserCredential credential;
    try {
      final credential = await auth.signInWithEmailAndPassword(
          email: email, password: password);

      //let's print the object returned by signInWithEmailAndPassword
      //you can use this object to get the user's id, email, etc.
      print(credential);
      return (credential.user?.uid);
    } on FirebaseAuthException catch (e) {
      return (e.code);
    }
  }

  Future<String?> signUp(String email, String password) async {
    UserCredential credential;
    try {
      credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      //let's print the object returned by signInWithEmailAndPassword
      //you can use this object to get the user's id, email, etc.\
      print(credential);

      return (credential.user?.uid);
    } on FirebaseAuthException catch (e) {
      /**
       * Can return:
       * - email-already-in-use
       * - invalid-email
       * - weak-password
       */
      return (e.code);
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  Future<User?> getCurrentUser() async{
    return await auth.currentUser;
  }
}

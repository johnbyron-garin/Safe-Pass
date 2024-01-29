import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../api/firebase_auth_api.dart';

class AuthProvider with ChangeNotifier {
  late FirebaseAuthAPI authService;
  late Stream<User?> uStream;
  late User? userObj;

  AuthProvider() {
    authService = FirebaseAuthAPI();
    fetchAuthentication();
    fetchUserObj();
  }

  Stream<User?> get userStream => uStream;
  User? get userObject => userObj;

  Future<void> fetchUserObj() async {
    userObj = await authService.getCurrentUser();
    notifyListeners();
  }

  void fetchAuthentication() {
    uStream = authService.getUser();

    notifyListeners();
  }

  Future<String?> signUp(String email, String password) async {
    var uid = await authService.signUp(email, password);
    signOut();
    notifyListeners();
    return uid;
  }

  Future<String?> signIn(String email, String password) async {
    var uid = await authService.signIn(email, password);
    await fetchUserObj();
    notifyListeners();
    return (uid);
  }

  Future<void> signOut() async {
    await authService.signOut();
    notifyListeners();
  }
}

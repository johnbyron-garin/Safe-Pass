import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe_pass/providers/auth_provider.dart';
import '/api/firebase_account_api.dart';
import '/models/account_model.dart';

class AccountProvider with ChangeNotifier {
  late FirebaseAccountAPI firebaseService;
  late DocumentReference<Map<String, dynamic>> _loggedInAccountStream;

  AccountProvider() {
    firebaseService = FirebaseAccountAPI();
  }

  DocumentReference<Map<String, dynamic>> get userAccount =>
      _loggedInAccountStream;

  // getter

  void fetchLoggedInAccount(BuildContext context) async {
    User? user = await context.read<AuthProvider>().userObj;
    print(user?.uid);
    _loggedInAccountStream = firebaseService.fetchUserAccountStream(user?.uid);
    notifyListeners();
  }

  void addAccount(Account acc, String userUID) async {
    String message = await firebaseService.addAccount(acc.toJson(acc), userUID);
    print(message);
    notifyListeners();
  }

  void setLatestEntry(String? userUID, String? entryID) async {
    await firebaseService.setLatestEntry(userUID, entryID);
    notifyListeners();
  }

  Future<Account?> getAccountByID(String? userUID) async {
    return await firebaseService.getAccountByID(userUID);
  }

  void setStatus(String? userUID, String? status) async {
    await firebaseService.setStatus(userUID, status);
    notifyListeners();
  }

  void elevateAccount(String? userUID, String? type) async {
    await firebaseService.elevateAccount(userUID, type);
    notifyListeners();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllStudentAccounts() {
    return firebaseService.getAllStudentAccounts();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getStudentByStatus(status) {
    return firebaseService.getStudentByStatus(status);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllStudentByCourse(course) {
    return firebaseService.getAllStudentByCourse(course);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllStudentByCollege(college) {
    return firebaseService.getAllStudentByCollege(college);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllStudentByStudentNo(
      studentNumber) {
    return firebaseService.getAllStudentByStudentNo(studentNumber);
  }
}

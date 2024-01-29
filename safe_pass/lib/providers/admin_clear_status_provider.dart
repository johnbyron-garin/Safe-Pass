import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/api/firebase_admin_clear_status_api.dart';

/**
 * A provider for account model, has only add function, implementation is similar to the
 * todo model
 */

class ClearStatusProvider with ChangeNotifier {
  late FirebaseAccountAPI firebaseService;

  ClearStatusProvider() {
    firebaseService = FirebaseAccountAPI();
  }

  Future<void> clearStatus(String userID) async {
    await firebaseService.clearStatus(userID);
    notifyListeners();
  }

}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/api/firebase_admin_addToQuarantine_api.dart';

/**
 * A provider for account model, has only add function, implementation is similar to the
 * todo model
 */

class AddToQuarantineProvider with ChangeNotifier {
  late FirebaseAccountAPI firebaseService;

  AddToQuarantineProvider() {
    firebaseService = FirebaseAccountAPI();
  }

  Future<void> addToQuarantine(String userID) async {
    await firebaseService.addToQuarantine(userID);
    notifyListeners();
  }

}

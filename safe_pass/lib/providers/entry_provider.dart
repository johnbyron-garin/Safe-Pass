import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/api/firebase_entry_api.dart';
import '/models/entry_model.dart';
import 'auth_provider.dart';

/**
 * A provider for account model, has only add function, implementation is similar to the
 * todo model
 */

class EntryProvider with ChangeNotifier {
  late FirebaseAccountAPI firebaseService;

  EntryProvider() {
    firebaseService = FirebaseAccountAPI();
  }

  Future<String?> addEntry(Entry ent) async {
    String? documentID = await firebaseService.addEntry(ent.toJson(ent));
    print("Added new entry: $documentID");
    notifyListeners();

    return documentID;
  }

  Future<void> replaceEntry(Entry details) async {
    await firebaseService.updateEntry(details);
    notifyListeners();
  }

  Future<void> removeEntry(String id) async {
    await firebaseService.removeEntry(id);
    notifyListeners();
  }

  Future<Entry?> getEntry(String id) async {
    var entry = await firebaseService.getEntryByID(id);
    notifyListeners();
    return entry;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> fetchUserEntries(BuildContext context) {
    User? user = context.read<AuthProvider>().userObj;
    var userEntriesStream = firebaseService.getEntriesFromUID(user?.uid);

    return userEntriesStream;
  }

  Future<void> setForApproval(String? entryID, bool forApproval) async {
    await firebaseService.setForApproval(entryID, forApproval);
    notifyListeners();
  }

}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:safe_pass/api/firebase_entry_request_api.dart';
import 'package:safe_pass/models/entry_request_model.dart';
import 'package:provider/provider.dart';

class EntryRequestProvider with ChangeNotifier {
  late FirebaseEntryRequestAPI firebaseService;

  EntryRequestProvider() {
    firebaseService = FirebaseEntryRequestAPI();
  }

  Future<void> addRequest(EntryRequest entryRequest) async {
    var docID = await firebaseService
        .addEntryRequest(entryRequest.toJson(entryRequest));
    print("Added request: $docID");

    notifyListeners();
  }

  Future<void> approveRequest(String? entryID, EntryRequest? request) async {
    await firebaseService.approveRequest(entryID, request);
    notifyListeners();
  }

  Future<void> rejectRequest(String? entryID, EntryRequest? request) async {
    await firebaseService.rejectRequest(entryID, request);
    notifyListeners();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getPendingRequests() {
    return firebaseService.getPendingRequests();
  }

}

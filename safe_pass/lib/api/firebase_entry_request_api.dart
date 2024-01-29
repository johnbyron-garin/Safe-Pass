import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_pass/models/entry_request_model.dart';

class FirebaseEntryRequestAPI {
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<String?> addEntryRequest(Map<String, dynamic>? entryRequest) async {
    try {
      final docRef = await db.collection("entry_request").add(entryRequest!);
      await db
          .collection("entry_request")
          .doc(docRef.id)
          .update({'id': docRef.id});

      return docRef.id;
    } on FirebaseException catch (e) {
      print("Failed with error '${e.code}: ${e.message}");
      return null;
    }
  }


  Future<void> approveRequest(String? entryID, EntryRequest? request) {

    try {
      db.collection('entry_request').doc(entryID).update({
        'status': 'approved',
      });

      if (request!.requestType == "edit") {
        db.collection('entries').doc(request.oldEntryID).update({
          'fluSymptoms': request.fluSymptoms,
          'respiratorySymptoms': request.respiratorySymptoms,
          'otherSymptoms': request.otherSymptoms,
          'forApproval': false,
        });
      } else if (request.requestType == "delete") {
        db.collection('entries').doc(request.oldEntryID).delete();
        db.collection('account_details').doc(request.userUID).update({
          'latestEntry': null, 'status': "cleared"
        });
      }
      return Future.value();
    } on FirebaseException catch (e) {
      return Future.error(e);
    }
  }

  Future<void> rejectRequest(String? entryID, EntryRequest? request) {
    try {
      db.collection('entry_request').doc(entryID).update({
        'status': 'rejected',
      });

      db.collection('entries').doc(request!.oldEntryID).update({
          'forApproval': false,
        });

      return Future.value();
    } on FirebaseException catch (e) {
      return Future.error(e);
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getPendingRequests() {
    return db
        .collection('entry_request')
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

}

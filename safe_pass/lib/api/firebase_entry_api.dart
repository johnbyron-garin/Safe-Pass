import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_pass/models/entry_model.dart';

/**
 * Created a FirebaseFirestore API for accounts, has only add feature
 */

class FirebaseAccountAPI {
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<String?> addEntry(Map<String, dynamic> entry) async {
    try {
      final docRef = await db.collection("entries").add(entry);
      await db.collection("entries").doc(docRef.id).update({'id': docRef.id, 'dateIssued': FieldValue.serverTimestamp()});

      return docRef.id;
    } on FirebaseException catch (e) {
      print("Failed with error '${e.code}: ${e.message}");
      return null;
    }
  }

  Future<String> removeEntry(String id) async {
    try {
      await db.collection("entries").doc(id).delete();

      return "Successfully deleted Account!";
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}";
    }
  }

  Future<String> updateEntry(Entry details) async {
    try {
      db.collection('entries').doc(details.id).update({
        'fluSymptoms': details.fluSymptoms,
        'respiratorySymptoms': details.respiratorySymptoms,
        'otherSymptoms': details.otherSymptoms
      });

      return 'Successfully updated entry';
    } on FirebaseException catch (e) {
      return 'Failed with error code: ${e.code}: ${e.message}';
    }
  }

  Future<Entry?> getEntryByID(String id) async {
    try {
      DocumentSnapshot documentSnapshot =
          await db.collection('entries').doc(id).get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> documentData =
            documentSnapshot.data() as Map<String, dynamic>;
        print("retrieved: $documentData");
        return Entry.fromJson(documentData);
      } else {
        return null;
      }
    } on FirebaseException catch (e) {
      return null;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getEntriesFromUID(
      String? userUID) {
    return db
        .collection('entries')
        .where('userUID', isEqualTo: userUID)
        .orderBy('dateIssued', descending: true)
        .snapshots();
  }

  Future<void> setForApproval(String? entryID, bool forApproval) {
    try {
      db.collection('entries').doc(entryID).update({
        'forApproval': forApproval,
      });
      return Future.value();
    } on FirebaseException catch (e) {
      return Future.error(e);
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/account_model.dart';

/**
 * Created a FirebaseFirestore API for accounts, has only add feature
 */

class FirebaseAccountAPI {
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<String> addAccount(Map<String, dynamic> acc, String userUID) async {
    try {
      final docRef =
          await db.collection("account_details").doc(userUID).set(acc);
      await db
          .collection("account_details")
          .doc(userUID)
          .update({'id': userUID});

      return "Successfully added Account!";
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}";
    }
  }

  Future<String> getUserID(String userUID) async {
    // Get a reference to the "account_details" collection
    CollectionReference accountDetailsCollection =
        FirebaseFirestore.instance.collection('account_details');

    // Build a query to retrieve the document with the specified userUID
    Query query = accountDetailsCollection.where('userUID', isEqualTo: userUID);

    // Execute the query and retrieve the documents
    QuerySnapshot querySnapshot = await query.get();

    // Get the first document found
    DocumentSnapshot documentSnapshot = querySnapshot.docs[0];

    // Convert the document to a Map
    Map<String, dynamic> documentData =
        documentSnapshot.data() as Map<String, dynamic>;

    // Return the document data as a Map
    return documentData['id'];
  }

  Future<void> setLatestEntry(String? userUID, String? entryID) {
    try {
      db.collection('account_details').doc(userUID).update({
        'latestEntry': entryID,
      });
      return Future.value();
    } on FirebaseException catch (e) {
      return Future.error(e);
    }
  }

  Future<Account?> getAccountByID(String? id) async {
    try {
      DocumentSnapshot documentSnapshot =
          await db.collection('account_details').doc(id).get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> documentData =
            documentSnapshot.data() as Map<String, dynamic>;
        print("retrieved: $documentData");
        return Account.fromJson(documentData);
      } else {
        return null;
      }
    } on FirebaseException catch (e) {
      return Future.error(e);
    }
  }

  Future<void> setStatus(String? userUID, String? status) {
    try {
      db.collection('account_details').doc(userUID).update({
        'status': status,
      });
      return Future.value();
    } on FirebaseException catch (e) {
      return Future.error(e);
    }
  }

  Future<void> elevateAccount(String? userUID, String? type) {
    try {
      db.collection('account_details').doc(userUID).update({
        'userType': type,
      });
      return Future.value();
    } on FirebaseException catch (e) {
      return Future.error(e);
    }
  }

  DocumentReference<Map<String, dynamic>> fetchUserAccountStream(
      String? documentID) {
    return db.collection("account_details").doc(documentID);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllStudentAccounts() {
    return db
        .collection("account_details")
        .where("userType", isEqualTo: "student")
        .orderBy("studentNumber", descending: false)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getStudentByStatus(
      String? status) {
    return db
        .collection("account_details")
        .where("userType", isEqualTo: "student")
        .where("status", isEqualTo: status)
        .orderBy("studentNumber", descending: false)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllStudentByCourse(
      String? course) {
    return db
        .collection("account_details")
        .where("userType", isEqualTo: "student")
        .where("course", isEqualTo: course)
        .orderBy("course", descending: false)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllStudentByCollege(
      String? college) {
    return db
        .collection("account_details")
        .where("userType", isEqualTo: "student")
        .where("college", isEqualTo: college)
        .orderBy("college", descending: false)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllStudentByStudentNo(
      String? studentNumber) {
    return db
        .collection("account_details")
        .where("userType", isEqualTo: "student")
        .where("studentNumber", isEqualTo: studentNumber)
        .orderBy("studentNumber", descending: false)
        .snapshots();
  }
}

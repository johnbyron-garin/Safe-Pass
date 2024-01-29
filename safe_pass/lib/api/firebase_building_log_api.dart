import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseBuildingLogAPI {
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<String?> addBuildingLog(Map<String, dynamic>? buildingLog) async {
    try {
      final docRef = await db.collection("building_logs").add(buildingLog!);
      await db
          .collection("building_logs")
          .doc(docRef.id)
          .update({'id': docRef.id});
      await db
          .collection("building_logs")
          .doc(docRef.id)
          .update({'dateScanned': FieldValue.serverTimestamp()});

      return docRef.id;
    } on FirebaseException catch (e) {
      print("Failed with error '${e.code}: ${e.message}");
      return null;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getLogsByHomeUnit(
      String? homeUnit) {
    return db
        .collection("building_logs")
        .where("homeUnit", isEqualTo: homeUnit)
        .orderBy("dateScanned", descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getLogsByStudentName(
      String? studentName) {
    return db
        .collection("building_logs")
        .where("studentName", isEqualTo: studentName)
        .orderBy("dateScanned", descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getLogsByDate(
      String? dateScanned) {
    return db
        .collection("building_logs")
        .where("dateScanned", isEqualTo: dateScanned)
        .orderBy("dateScanned", descending: true)
        .snapshots();
  }
}

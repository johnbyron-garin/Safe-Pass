import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseTimeAPI {
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<void> initTime() {
    return db.collection('time').doc('server_time').set({
      'time': FieldValue.serverTimestamp(),
    });
  }

  Future<Timestamp?> getTime() async {
    DocumentSnapshot documentSnapshot =
        await db.collection('time').doc('server_time').get();

    if (documentSnapshot.exists) {
      Map<String, dynamic> documentData =
          documentSnapshot.data() as Map<String, dynamic>;
      print("retrieved: $documentData");
      return documentData['time'];
    } else {
      print("Document does not exist on the database");
      return null;
    }
  }
}
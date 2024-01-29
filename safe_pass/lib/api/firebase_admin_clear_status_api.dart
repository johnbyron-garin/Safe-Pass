import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_pass/models/account_model.dart';

/**
 * Created a FirebaseFirestore API for accounts, has only add feature
 */

class FirebaseAccountAPI {
  static final FirebaseFirestore db = FirebaseFirestore.instance;

 Future<Account?> getAccountByID(String uid) async {
    try {
      DocumentSnapshot documentSnapshot =
          await db.collection('account_details').doc(uid).get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> documentData =
            documentSnapshot.data() as Map<String, dynamic>;
        print("retrieved: $documentData");
        return Account.fromJson(documentData);
      } else {
        return null;
      }
    } on FirebaseException catch (e) {
      return null;
    }
  }

  Future<void> clearStatus(String? userUID) async {
    try {
      final data = await getAccountByID(userUID!);
      if (data!.status == 'monitoring' || data!.status == 'quarantined') {
        db.collection('account_details').doc(userUID).update({'status': 'cleared'});
      }
    } on FirebaseException catch (e) {
      return Future.error(e);
    }
  }

}

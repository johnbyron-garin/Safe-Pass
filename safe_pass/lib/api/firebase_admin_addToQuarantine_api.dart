import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_pass/models/account_model.dart';

/**
 * Created a FirebaseFirestore API for accounts, has only add feature
 */

class FirebaseAccountAPI {
  static final FirebaseFirestore db = FirebaseFirestore.instance;

 Future<Account?> getAccountByID(String id) async {
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
      return null;
    }
  }

  Future<void> addToQuarantine(String? userID) async {
    try {
      final data = await getAccountByID(userID!);
      db.collection('account_details').doc(userID).update({'status': 'quarantined'});
    } on FirebaseException catch (e) {
      return Future.error(e);
    }
  }

}

import 'package:flutter/foundation.dart';

import '../api/firebase_time_api.dart';

class TimeProvider with ChangeNotifier {
  late FirebaseTimeAPI firebaseService;

  TimeProvider() {
    firebaseService = FirebaseTimeAPI();
  }

  Future<void> initTime() async {
    await firebaseService.initTime();
    notifyListeners();
  }

  Future<DateTime?> getTime() async {
    await initTime();
    var time = await firebaseService.getTime();
    notifyListeners();
    return time?.toDate();
  }
}

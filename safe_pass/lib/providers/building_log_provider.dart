import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:safe_pass/models/buildinglog_model.dart';

import '../api/firebase_building_log_api.dart';

class BuildingLogProvider with ChangeNotifier {
  late FirebaseBuildingLogAPI firebaseService;

  BuildingLogProvider() {
    firebaseService = FirebaseBuildingLogAPI();
  }

  Future<String?> addBuildingLog(BuildingLog buildingLog) async {
    final String? id = await firebaseService.addBuildingLog(buildingLog.toJson(buildingLog));
    return id;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getLogsByHomeUnit(String? homeUnit) {
    return firebaseService.getLogsByHomeUnit(homeUnit);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getLogsByStudentName(String? studentName) {
    return firebaseService.getLogsByStudentName(studentName);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getLogsByDate(String? dateScanned) {
    return firebaseService.getLogsByDate(dateScanned);
  }
}
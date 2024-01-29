import 'dart:convert';

/**
 * Created a model for Account, for storing into the database
 */

class BuildingLog {
  DateTime? dateScanned;
  String? id;
  String? entryDocumentID;
  String? userUID;
  String? employeeUID;
  String? studentName;
  String? homeUnit;

  BuildingLog(
      {required this.entryDocumentID,
      required this.userUID,
      required this.employeeUID,
      required this.studentName,
      required this.homeUnit,
      this.id,
      this.dateScanned,
      });

  // Factory constructor to instantiate object from json format
  factory BuildingLog.fromJson(Map<String, dynamic> json) {
    return BuildingLog(
      entryDocumentID: json['entryDocumentID'],
      userUID: json['userUID'],
      employeeUID: json['employeeUID'],
      id: json['id'],
      studentName: json['studentName'],
      homeUnit: json['homeUnit'],
      dateScanned: json['dateScanned']?.toDate(),
    );
  }

  static List<BuildingLog> fromJsonArray(String jsonData) {
    final Iterable<dynamic> data = jsonDecode(jsonData);
    return data
        .map<BuildingLog>((dynamic d) => BuildingLog.fromJson(d))
        .toList();
  }

  Map<String, dynamic> toJson(BuildingLog buildingLog) {
    return {
      'entryDocumentID': buildingLog.entryDocumentID,
      'userUID': buildingLog.userUID,
      'employeeUID': buildingLog.employeeUID,
      'id': buildingLog.id,
      'studentName': buildingLog.studentName,
      'homeUnit': buildingLog.homeUnit,
      'dateScanned': buildingLog.dateScanned,
    };
  }
}

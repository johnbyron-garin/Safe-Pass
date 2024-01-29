import 'dart:convert';

class EntryRequest {
  // General
  String? id;
  String? studentName;
  String requestType;
  String oldEntryID;
  Map<String, dynamic>? fluSymptoms;
  Map<String, dynamic>? respiratorySymptoms;
  Map<String, dynamic>? otherSymptoms;
  bool? exposureReport;
  String reason;
  String status;
  String userUID;

  EntryRequest({
    this.id,
    required this.studentName,
    required this.requestType,
    required this.oldEntryID,
    this.fluSymptoms,
    this.respiratorySymptoms,
    this.otherSymptoms,
    this.exposureReport,
    required this.reason,
    required this.status,
    required this.userUID,
  });

  // Factory constructor to instantiate object from json format
  factory EntryRequest.fromJson(Map<String, dynamic> json) {
    return EntryRequest(
      id: json['id'],
      studentName: json['studentName'],
      requestType: json['requestType'],
      oldEntryID: json['oldEntryID'],
      fluSymptoms: json['fluSymptoms'] as Map<String, dynamic>?,
      respiratorySymptoms: json['respiratorySymptoms'] as Map<String, dynamic>?,
      otherSymptoms: json['otherSymptoms'] as Map<String, dynamic>?,
      exposureReport: json['exposureReport'],
      reason: json['reason'],
      status: json['status'],
      userUID: json['userUID'],
    );
  }

  static List<EntryRequest> fromJsonArray(String jsonData) {
    final Iterable<dynamic> data = jsonDecode(jsonData);
    return data
        .map<EntryRequest>((dynamic d) => EntryRequest.fromJson(d))
        .toList();
  }

  Map<String, dynamic> toJson(EntryRequest req) {
    return {
      'id': req.id,
      'studentName': req.studentName,
      'requestType': req.requestType,
      'oldEntryID': req.oldEntryID,
      'fluSymptoms': req.fluSymptoms,
      'respiratorySymptoms': req.respiratorySymptoms,
      'otherSymptoms': req.otherSymptoms,
      'exposureReport': req.exposureReport,
      'reason': req.reason,
      'status': req.status,
      'userUID': req.userUID,
    };
  }
}

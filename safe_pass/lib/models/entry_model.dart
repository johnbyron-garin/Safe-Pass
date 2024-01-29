import 'dart:convert';

/**
 * Created a model for Account, for storing into the database
 */

class Entry {
  DateTime? dateIssued;
  String? id;
  Map<String, dynamic> fluSymptoms;
  Map<String, dynamic> respiratorySymptoms;
  Map<String, dynamic> otherSymptoms;
  bool exposureReport;
  String? userUID;

  bool? forApproval;

  Entry({
    this.id,
    this.dateIssued,
    required this.fluSymptoms,
    required this.respiratorySymptoms,
    required this.userUID,
    required this.otherSymptoms,
    required this.exposureReport,
    this.forApproval
  });

  // Factory constructor to instantiate object from json format
  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
        dateIssued: json['dateIssued']?.toDate(),
        id: json['id'],
        fluSymptoms: json['fluSymptoms'] as Map<String, dynamic>,
        respiratorySymptoms:
            json['respiratorySymptoms'] as Map<String, dynamic>,
        otherSymptoms: json['otherSymptoms'] as Map<String, dynamic>,
        exposureReport: json['exposureReport'],
        userUID: json['userUID'],
        forApproval: json['forApproval']
    );
  }

  static List<Entry> fromJsonArray(String jsonData) {
    final Iterable<dynamic> data = jsonDecode(jsonData);
    return data.map<Entry>((dynamic d) => Entry.fromJson(d)).toList();
  }

  Map<String, dynamic> toJson(Entry ent) {
    return {
      'dateIssued': ent.dateIssued,
      'id': ent.id,
      'fluSymptoms': ent.fluSymptoms,
      'respiratorySymptoms': ent.respiratorySymptoms,
      'otherSymptoms': ent.otherSymptoms,
      'exposureReport': ent.exposureReport,
      'userUID': ent.userUID,
      'forApproval': ent.forApproval
    };
  }
}

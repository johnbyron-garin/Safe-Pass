import 'dart:convert';

class Account {
  // General
  String? id;
  String? userUID;
  String userType;
  String name;
  String email;
  String username;

  // Student
  String? college;
  String? course;
  String? studentNumber;
  String? preExistingIllness;
  String? allergies;

  // Admin and Entrance Monitor
  String? employeeNo;
  String? position;
  String? homeUnit;

  // Health info
  String? latestEntry;
  String status;

  Account(
      {this.id,
      this.userUID,
      required this.userType,
      required this.name,
      required this.email,
      required this.username,

      // Student
      this.college,
      this.course,
      this.studentNumber,
      this.preExistingIllness,
      this.allergies,

      // Admin and Entrance Monitor
      this.employeeNo,
      this.position,
      this.homeUnit,

      // Health info
      this.latestEntry,
      required this.status});

  // Factory constructor to instantiate object from json format
  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
        id: json['id'],
        userType: json['userType'],
        name: json['name'],
        email: json['email'],
        username: json['username'],
        college: json['college'],
        course: json['course'],
        studentNumber: json['studentNumber'],
        preExistingIllness: json['preExistingIllness'],
        allergies: json['allergies'],
        employeeNo: json['employeeNo'],
        position: json['position'],
        homeUnit: json['homeUnit'],
        latestEntry: json['latestEntry'],
        status: json['status']);
  }

  static List<Account> fromJsonArray(String jsonData) {
    final Iterable<dynamic> data = jsonDecode(jsonData);
    return data.map<Account>((dynamic d) => Account.fromJson(d)).toList();
  }

  Map<String, dynamic> toJson(Account acc) {
    return {
      'id': acc.id,
      'userType': acc.userType,
      'name': acc.name,
      'email': acc.email,
      'username': acc.username,
      'college': acc.college,
      'course': acc.course,
      'studentNumber': acc.studentNumber,
      'preExistingIllness': acc.preExistingIllness,
      'allergies': acc.allergies,
      'employeeNo': acc.employeeNo,
      'position': acc.position,
      'homeUnit': acc.homeUnit,
      'latestEntry': acc.latestEntry,
      'status': acc.status
    };
  }
}

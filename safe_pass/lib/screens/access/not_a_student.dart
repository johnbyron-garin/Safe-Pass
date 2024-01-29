import 'package:flutter/material.dart';
import 'package:safe_pass/screens/access/signup_employee.dart';

import '../../styles.dart';

class NotAStudent extends StatefulWidget {
  const NotAStudent({super.key});
  @override
  _NotAStudentState createState() => _NotAStudentState();
}

class _NotAStudentState extends State<NotAStudent> {
  @override
  Widget _whoAreYouContainer() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Who are you?",
          style: Styles.titleTextStyle_Pass,
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text('Select the type of account you want to create.'),
        ),
      ],
    );
  }

  Widget _adminOrEntranceMonitor() {
    return Column(
      children: [
        Card(
          clipBehavior: Clip.hardEdge,
          color: Theme.of(context).colorScheme.primaryContainer,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    SignupEmployee(userType: "admin"),
              ),
            );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ListTile(
                leading: Icon(Icons.verified_user_outlined, size: 60.0),
                title: Text(
                  'Admin',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ),
        ),
        Card(
          clipBehavior: Clip.hardEdge,
          color: Theme.of(context).colorScheme.primaryContainer,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    SignupEmployee(userType: "entrance_monitor"),
              ),
            );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ListTile(
                leading: Icon(Icons.desktop_windows_outlined, size: 60.0),
                title: Text(
                  'Entrance Monitor',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.only(left: 40.0, right: 40.0),
        children: <Widget>[
          _whoAreYouContainer(),
          _adminOrEntranceMonitor(),
        ],
      ),
    );
  }
}

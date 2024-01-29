import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe_pass/screens/misc/SideDrawer.dart';
import 'package:safe_pass/screens/misc/admin_sideDrawer.dart';

import '../../models/account_model.dart';
import '../../providers/account_provider.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    DocumentReference<Map<String, dynamic>> userStream =
        context.watch<AccountProvider>().userAccount;
    Stream<QuerySnapshot<Map<String, dynamic>>> studentsStream =
        context.watch<AccountProvider>().getAllStudentAccounts();

    return StreamBuilder(
      stream: userStream.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Error",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
                  Text("${snapshot.error}",
                      style: TextStyle(fontWeight: FontWeight.w300))
                ],
              ),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Error",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
                  Text("${snapshot.error}",
                      style: TextStyle(fontWeight: FontWeight.w300))
                ],
              ),
            ),
          );
        }

        Account account = Account.fromJson(snapshot.data!.data()!);
        return StreamBuilder(
          stream: studentsStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Scaffold(
                appBar: AppBar(),
                body: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Error",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 25)),
                      Text("${snapshot.error}",
                          style: TextStyle(fontWeight: FontWeight.w300))
                    ],
                  ),
                ),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                appBar: AppBar(),
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            List students = snapshot.data!.docs;
            return _dashBoardScaffold(account, students);
          },
        );
      },
    );
  }

  Widget _dashBoardScaffold(Account account, List students) {
    return Scaffold(
      appBar: AppBar(),
      drawer: SideDrawer(
        status: account.userType,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: ListView(
          // shrinkWrap: true,
          children: [
            _title(),
            _totalNumberofStudents(students),
            _clearedStudents(students),
            _underMonitoring(students),
            _underQuarantine(students),
          ],
        ),
      ),
    );
  }

  Widget _title() {
    return const Text(
      "Dashboard",
      style: TextStyle(
        fontSize: 42,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _totalNumberofStudents(List students) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Card(
          color: Theme.of(context).colorScheme.tertiaryContainer,
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/student-list');
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: ListTile(
                // contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                leading: Icon(
                  Icons.info_outline,
                  size: 40,
                ),
                title: Column(
                  children: [
                    Text(
                      "Total Number of Students",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
                trailing: Column(
                  children: [
                    Text(
                      students.length.toString(),
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  Widget _clearedStudents(List students) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Card(
          clipBehavior: Clip.hardEdge,
          color: Theme.of(context).colorScheme.primaryContainer,
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/cleared-student-list');
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                // contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Cleared Students",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
                trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        students
                            .where((element) => element['status'] == 'cleared')
                            .length
                            .toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 30),
                      ),
                    ]),
              ),
            ),
          ),
        ));
  }

  Widget _underMonitoring(List students) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Card(
          clipBehavior: Clip.hardEdge,
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/under-monitoring');
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                // contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                title: Column(
                  children: [
                    Text(
                      "Students Under Monitoring",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
                trailing: Column(
                  children: [
                    Text(
                      students
                          .where((element) => element['status'] == 'monitoring')
                          .length
                          .toString(),
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  Widget _underQuarantine(List students) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Card(
          clipBehavior: Clip.hardEdge,
          color: Theme.of(context).colorScheme.errorContainer,
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/under-quarantine');
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                // contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                title: Column(
                  children: [
                    Text(
                      "Students Under Quarantine",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
                trailing: Column(
                  children: [
                    Text(
                      students
                          .where(
                              (element) => element['status'] == 'quarantined')
                          .length
                          .toString(),
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}

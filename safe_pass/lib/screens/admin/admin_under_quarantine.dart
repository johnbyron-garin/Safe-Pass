import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe_pass/screens/admin/admin_quarantinePopout.dart';
import 'package:safe_pass/screens/misc/admin_sideDrawer.dart';

import '../../models/account_model.dart';
import '../../providers/account_provider.dart';

class UnderQuarantine extends StatefulWidget {
  const UnderQuarantine({super.key});

  _UnderQuarantineState createState() => _UnderQuarantineState();
}

class _UnderQuarantineState extends State<UnderQuarantine> {
  int no_of_students = 0;
  @override
  Widget build(BuildContext context) {
    DocumentReference<Map<String, dynamic>> userStream =
        context.watch<AccountProvider>().userAccount;

    return StreamBuilder(
      stream: userStream.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
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

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
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

        var data = snapshot.data?.data() as Map<String, dynamic>;

        // print("${data} + @@@@");
        return _studentListScaffold(Account.fromJson(data));
      },
    );
  }

  Widget _studentListScaffold(Account account) {
     return Scaffold(
      appBar: AppBar(),
      drawer: AdminSideDrawer(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: ListView(
          // shrinkWrap: true,
          children: [
            _title(),
            _studentList(context, account),
          ],
        ),
      ),
    );
  }

  Widget _title() {
    return const Text(
      "Students Under Quarantine",
      style: TextStyle(
        fontSize: 42,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _totalNumberofStudentsUnderQuarantine(int total) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Card(
          color: Theme.of(context).colorScheme.tertiaryContainer,
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
                    "Total Number of Students Under Quarantine",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ],
              ),
              trailing: Column(
                children: [
                  Text(
                    "$total",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _studentList(BuildContext context, Account account) {
    Stream<QuerySnapshot<Map<String, dynamic>>> studentListStream = context
        .watch<AccountProvider>()
        .getStudentByStatus("quarantined");

    return StreamBuilder(
      stream: studentListStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error);
          return Center(
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
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _noEntryYet(context);
        }

        List students = snapshot.data!.docs;
        no_of_students = students.length;

        return Column(
          children: [
            _totalNumberofStudentsUnderQuarantine(no_of_students),
            Divider(),
            Column(
              children: students.map<Padding>((var value) {
                Color color = Theme.of(context).colorScheme.secondaryContainer;
                Icon icon = Icon(
                  Icons.account_circle_outlined,
                  size: 40,
                );

                var student =
                    Account.fromJson(value.data() as Map<String, dynamic>);

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Card(
                    color: color,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 2),
                      child: ListTile(
                        leading: icon,
                        title: Text(
                          student.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          student.course!,
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: ((context) => QuarantinePopout(student: student)));
                        },
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      }
    );
  }

  Widget _noEntryYet(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Card(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
              leading: Icon(
                Icons.info_outline,
                size: 40,
              ),
              title: Text(
                "No students yet.",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
          ),
        ),
      ),
    );
  }
}

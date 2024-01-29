import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe_pass/models/entry_request_model.dart';
import 'package:safe_pass/providers/entry_request_provider.dart';
import 'package:safe_pass/screens/admin/admin_editRequestPopout.dart';
import 'package:safe_pass/screens/misc/SideDrawer.dart';
import 'package:safe_pass/screens/misc/admin_sideDrawer.dart';

import '../../models/account_model.dart';
import '../../providers/account_provider.dart';

class PendingRequests extends StatefulWidget {
  const PendingRequests({super.key});

  _PendingRequestsState createState() => _PendingRequestsState();
}

class _PendingRequestsState extends State<PendingRequests> {
  var students = [
    {
      "name": "Dela Cruz, Juan",
      "course": "Computer Science",
    },
    {
      "name": "Dela Cruz, Juan",
      "course": "Computer Science",
    },
    {
      "name": "Dela Cruz, Juan",
      "course": "Computer Science",
    },
    {
      "name": "Dela Cruz, Juan",
      "course": "Computer Science",
    },
  ];
  @override
  Widget build(BuildContext context) {
    DocumentReference<Map<String, dynamic>> userStream =
        context.watch<AccountProvider>().userAccount;

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
          } else if (!snapshot.hasData) {
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
          }

          Account account = Account.fromJson(snapshot.data!.data()!);
          return _pendingRequestScaffold(account);
        });
  }

  Widget _pendingRequestScaffold(Account? account) {
    return Scaffold(
      appBar: AppBar(),
      drawer: SideDrawer(status: account!.userType),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: ListView(
          // shrinkWrap: true,
          children: [
            _title(),
            _subtitle(),
            _studentList(),
          ],
        ),
      ),
    );
  }

  Widget _title() {
    return const Text(
      "Pending Edit Requests",
      style: TextStyle(
        fontSize: 42,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _subtitle() {
    return const Text(
      "These are the students who requested to edit their entry. Approve or reject them by pressing the ellipsis.",
      style: TextStyle(
        fontWeight: FontWeight.w300,
      ),
    );
  }

  Widget _studentList() {
    Stream<QuerySnapshot<Map<String, dynamic>>> pendingRequestsList =
        context.watch<EntryRequestProvider>().getPendingRequests();

    return StreamBuilder(
        stream: pendingRequestsList,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
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
          } else if (!snapshot.hasData) {
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
          }

          List requests = snapshot.data!.docs;
          List pendingRequests = [];
          for (var request in requests) {
            print(request.data() as Map<String, dynamic>);
            pendingRequests.add(request.data() as Map<String, dynamic>);
          }

          if (pendingRequests.isEmpty) {
            return _noEntryYet(context);
          }

          return _pendingRequestBody(pendingRequests, context);
        });
  }

  Widget _pendingRequestBody(List requests, BuildContext context) {
    return Column(
      children: requests.map<Padding>((varvalue) {
        Color color = Theme.of(context).colorScheme.secondaryContainer;
        Icon icon = Icon(
          Icons.account_circle_outlined,
          size: 40,
        );

        EntryRequest request = EntryRequest.fromJson(varvalue);

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Card(
            color: color,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 2),
              child: ListTile(
                leading: icon,
                trailing: ellipsis(context, request),
                title: Text(
                  request.studentName!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  request.requestType,
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
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

  Widget ellipsis(BuildContext context, EntryRequest? request) {
    return GestureDetector(
      onTap: () {
        showDialog(
            context: context,
            builder: ((context) {
              var title = "";
              if (request!.requestType == "edit") {
                title = "Edit Entry Request";
              } else if (request.requestType == "delete") {
                title = "Delete Entry Request";
              }

              return AlertDialog(
                title: Text(title),
                content: Text("Reason:\n${request.reason}"),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Cancel")),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.read<EntryRequestProvider>().rejectRequest(
                          request.id, request);
                    },
                    child: Text("Reject"),
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.read<EntryRequestProvider>().approveRequest(
                            request.id, request);
                      },
                      child: Text("Approve")),
                ],
              );
            }));
      },
      child: Icon(Icons.more_horiz, size: 40),
    );
  }
}

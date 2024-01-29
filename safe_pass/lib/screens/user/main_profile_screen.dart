import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe_pass/screens/user/generate_buildingpass.dart';

import '../../models/account_model.dart';
import '../../models/entry_model.dart';
import '../../providers/account_provider.dart';
import '../../providers/entry_provider.dart';
import '../../providers/time_provider.dart';
import '../../styles.dart';
import '../misc/SideDrawer.dart';
import 'student_entryHistory.dart';
import 'student_userInfo.dart';

class MainProfile extends StatefulWidget {
  const MainProfile({super.key});
  @override
  _MainProfileState createState() => _MainProfileState();
}

class _MainProfileState extends State<MainProfile> {
  var hasEntry;

  Widget _MainProfileContainer() {
    return Text(
      "Profile",
      style: TextStyle(
        fontSize: 42,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _userInformation(Account account) {
    return Card(
      clipBehavior: Clip.hardEdge,
      color: Theme.of(context).colorScheme.tertiaryContainer,
      child: InkWell(
        onTap: () {
          showDialog(
              context: context,
              builder: ((context) => UserInformation(
                    account: account,
                  )));
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: ListTile(
              leading: Icon(Icons.account_circle_rounded, size: 40),
              title: Text(
                'User Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(account.name)),
        ),
      ),
    );
  }

  Widget _viewBuildingQRCode(Account account, Entry? entry) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Card(
            clipBehavior: Clip.hardEdge,
            color: Theme.of(context).colorScheme.primaryContainer,
            child: InkWell(
              onTap: () {
                if (hasEntry) {
                  showDialog(
                      context: context,
                      builder: ((context) => GenerateBuildingPass(
                          entry: _packageEntry(entry),
                          exitToHome: false,
                          documentID: entry!.id,
                          userUID: account.id, dateIssued: entry.dateIssued)));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        "No entry for today. Generate a building pass at Home tab."),
                  ));
                }
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'View Building Pass\nQR Code',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Icon(Icons.qr_code_rounded, size: 60.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _entryList() {
    Stream<QuerySnapshot<Map<String, dynamic>>> recentEntriesStream =
        context.read<EntryProvider>().fetchUserEntries(context);

    return StreamBuilder(
      stream: recentEntriesStream,
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
        }

        List entries = snapshot.data!.docs;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Card(
            clipBehavior: Clip.hardEdge,
            color: Theme.of(context).colorScheme.primaryContainer,
            child: InkWell(
              onTap: () {
                Navigator.of(context).pushReplacementNamed("/entry-history");
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'List of Entries',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            entries.length.toString(),
                            style: TextStyle(
                              height: 0.9,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Entries',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ]),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Map<String, dynamic> _packageEntry(Entry? entry) {
    Map<String, dynamic> packagedEntry = {};
    packagedEntry
      ..addAll(entry!.fluSymptoms)
      ..addAll(entry.respiratorySymptoms)
      ..addAll(entry.otherSymptoms);
    packagedEntry['Exposure Report'] = entry.exposureReport;

    return packagedEntry;
  }

  Widget _profileBody(Account account, Entry? entry) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      children: <Widget>[
        _MainProfileContainer(),
        _userInformation(account),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: const Divider(),
        ),
        _viewBuildingQRCode(account, entry),
        _entryList(),
      ],
    );
  }

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
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
                Text("${snapshot.error}",
                    style: TextStyle(fontWeight: FontWeight.w300))
              ],
            )),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (!snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: Text("No data"),
            ),
          );
        } else {
          var data = snapshot.data?.data() as Map<String, dynamic>;

          return Scaffold(
            appBar: AppBar(),
            body: FutureBuilder<Entry?>(
                future: setHasEntry(data['latestEntry'],
                    context.read<EntryProvider>(), context.read<TimeProvider>()),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
          
                  return _profileBody(Account.fromJson(data), snapshot.data);
                }),
            drawer: Builder(
                builder: (context) => SideDrawer(status: data['userType'])),
          );
        }
      },
    );

    // return Scaffold(
    //   appBar: AppBar(),
    //   drawer: Builder(builder: (context) => SideDrawer()),
    //   body: StreamBuilder(
    //     stream: userStream.snapshots(),
    //     builder: (context, snapshot) {
    //       if (snapshot.hasError) {
    //         return Center(
    //             child: Column(
    //           crossAxisAlignment: CrossAxisAlignment.center,
    //           children: [
    //             Text("Error",
    //                 style:
    //                     TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
    //             Text("${snapshot.error}",
    //                 style: TextStyle(fontWeight: FontWeight.w300))
    //           ],
    //         ));
    //       } else if (snapshot.connectionState == ConnectionState.waiting) {
    //         return Center(
    //           child: CircularProgressIndicator(),
    //         );
    //       } else if (!snapshot.hasData) {
    //         return Center(
    //           child: Text("No data"),
    //         );
    //       } else {
    //         var data = snapshot.data?.data() as Map<String, dynamic>;

    //         return FutureBuilder<Entry?>(
    //             future: setHasEntry(
    //                 data['latestEntry'],
    //                 context.read<EntryProvider>(),
    //                 context.read<TimeProvider>()),
    //             builder: (context, snapshot) {
    //               if (snapshot.connectionState == ConnectionState.waiting) {
    //                 return Center(
    //                   child: CircularProgressIndicator(),
    //                 );
    //               }

    //               return _profileBody(Account.fromJson(data), snapshot.data);
    //             });
    //       }
    //     },
    //   ),
    // );
  }

  Future<Entry?> setHasEntry(
    String? entryID,
    EntryProvider entryProvider,
    TimeProvider timeProvider,
  ) async {
    if (entryID == null || entryID == "") {
      hasEntry = false;
      return null;
    }

    var entry = await entryProvider.getEntry(entryID);

    var serverDate = await timeProvider.getTime();
    var currentDayOnly = DateTime(
      serverDate!.year,
      serverDate.month,
      serverDate.day,
    ); // remove time from current date
    var entryDateIssued = entry!.dateIssued;
    var entryDate = DateTime(
      entryDateIssued!.year,
      entryDateIssued.month,
      entryDateIssued.day,
    );

    if (currentDayOnly == entryDate) {
      hasEntry = true;
    } else {
      hasEntry = false;
    }

    return entry;
  }
}

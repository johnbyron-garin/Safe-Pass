import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe_pass/models/account_model.dart';
import 'package:safe_pass/providers/entry_provider.dart';
import 'package:safe_pass/providers/time_provider.dart';
import 'package:safe_pass/screens/misc/SideDrawer.dart';
import 'package:safe_pass/screens/user/add_entry.dart';
import 'package:safe_pass/screens/user/already_has_entry.dart';

import '../../models/entry_model.dart';
import '../../providers/account_provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var hasEntry;
  var userUID;

  @override
  Widget build(BuildContext context) {
    DocumentReference<Map<String, dynamic>> userStream =
        context.watch<AccountProvider>().userAccount;

    print(userStream);

    return StreamBuilder<DocumentSnapshot>(
        stream: userStream.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
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
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 25)),
                    Text("${snapshot.error}",
                        style: TextStyle(fontWeight: FontWeight.w300))
                  ],
                ),
              ),
            );
          }

          var data = snapshot.data?.data() as Map<String, dynamic>;
          userUID = data['id'];

          print("${data} + @@@@");

          return Scaffold(
            appBar: AppBar(),
            body: FutureBuilder<Entry?>(
                future: setHasEntry(
                    data['latestEntry'],
                    context.read<EntryProvider>(),
                    context.read<TimeProvider>()),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return _homeBody(Account.fromJson(data), snapshot.data);
                }),
            drawer: Builder(
                builder: (context) => SideDrawer(status: data['userType'])),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                if (hasEntry) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => const AlreadyHasEntry()),
                  );
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => AddEntry(
                              userID: userUID,
                            )),
                  );
                }
              },
            ),
          );
        });
  }

  Widget _homeBody(Account userAccount, Entry? latestEntry) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: ListView(
        // shrinkWrap: true,
        children: [
          _title(userAccount.name),
          if (hasEntry) _status(userAccount.status),
          _todaysEntryWrapper(hasEntry, latestEntry),
          _quarantineStatusWrapper(userAccount.status == "quarantined"),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: const Divider(),
          ),
          _recentEntryTitle(),
          _recentEntryList(context),
          Padding(
            padding: const EdgeInsets.only(bottom: 70, top: 8),
            child: Center(
              child: Text("Go to Entry History to view all entries."),
            ),
          ),
        ],
      ),
    );
  }

  Widget _title(String name) {
    return Text(
      // "Home",
      "👋 $name",
      style: TextStyle(
        fontSize: 42,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _todaysEntryWrapper(bool hasEntryToday, Entry? latestEntry) {
    if (hasEntryToday) {
      return _entryToday(latestEntry);
    }

    return _noEntryToday();
  }

  Widget _entryToday(Entry? latestEntry) {
    var dateOfEntry = latestEntry!.dateIssued;

    String formattedDate = DateFormat('h:mm a MMMM d, y').format(DateTime(
      dateOfEntry!.year,
      dateOfEntry.month,
      dateOfEntry.day,
      dateOfEntry.hour,
      dateOfEntry.minute,
    ));

    var summarizedEntry = _summarizeEntry(latestEntry);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Card(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            // contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            leading: Icon(
              Icons.info_outline,
              size: 40,
            ),
            title: Text(
              "Latest Entry",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formattedDate,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  summarizedEntry[0],
                  style: TextStyle(fontWeight: FontWeight.w300),
                ),
                Text(summarizedEntry[1],
                    style: TextStyle(fontWeight: FontWeight.w300))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _noEntryToday() {
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
                "No entry submitted for today.",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Submit one via the Add tab.",
                  style: TextStyle(fontWeight: FontWeight.w300))),
        ),
      ),
    );
  }

  /**
   * Status:
   *  - cleared
   *  - monitoring
   *  - quarantine
   */

  Widget _status(String status) {
    var statusTitle = "";
    var statusSubtitle = "";

    switch (status) {
      case "cleared":
        statusTitle = "You're good to go!";
        statusSubtitle = "View your building pass QR code in the Profiles tab.";
        break;
      case "monitoring":
        statusTitle = "You're under monitoring.";
        statusSubtitle = "Please follow proper monitoring guidelines.";
        break;
      case "quarantined":
        statusTitle = "You're under quarantine.";
        statusSubtitle = "Please follow proper quarantine guidelines.";
        break;
      default:
        statusTitle = "No status.";
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            statusTitle,
            style: TextStyle(fontWeight: FontWeight.w300, fontSize: 28),
          ),
          Text(
            statusSubtitle,
            style: TextStyle(fontWeight: FontWeight.w300, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _quarantineStatusWrapper(bool underQuarantine) {
    if (underQuarantine) {
      return _underQuarantine();
    }

    return _notUnderQuarantine();
  }

  Widget _underQuarantine() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Card(
        color: Theme.of(context).colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
              leading: Icon(
                Icons.house_outlined,
                size: 40,
              ),
              title: Text(
                "Quarantine Status",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      "During your quarantine period, you are not permitted to generate a building pass.",
                      style: TextStyle(fontWeight: FontWeight.w300)),
                ],
              )),
        ),
      ),
    );
  }

  Widget _notUnderQuarantine() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Card(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
              leading: Icon(
                Icons.house_outlined,
                size: 40,
              ),
              title: Text(
                "Quarantine Status",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Not quarantined.",
                      style: TextStyle(fontWeight: FontWeight.w300)),
                ],
              )),
        ),
      ),
    );
  }

  Widget _recentEntryTitle() {
    return const Text(
      "Recent Entries",
      style: TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _recentEntryList(BuildContext context) {
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
          } else if (!snapshot.hasData) {
            return Container();
          }

          List entries = snapshot.data!.docs;
          List recentEntries =
              entries.length > 5 ? entries.sublist(0, 5) : List.from(entries);

          return Column(
            children: recentEntries.map<Padding>((var value) {
              var castedValue = value.data() as Map<String, dynamic>;
              var entryObject = Entry.fromJson(castedValue);
              var summarizedEntry = _summarizeEntry(entryObject);
              var remarks = "";

              if (summarizedEntry[2] == 'quarantined') {
                remarks = "Has symptoms.";
              } else if (summarizedEntry[3]) {
                remarks = "Has face-to-face encounter with a confirmed case.";
              } else {
                remarks = "No symptoms. Building pass generated";
              }

              var dateOfEntry = entryObject.dateIssued;

              String formattedDate = 'Unknown';

              if (dateOfEntry != null) {
                formattedDate = DateFormat('h:mm a MMMM d, y').format(DateTime(
                  dateOfEntry.year,
                  dateOfEntry.month,
                  dateOfEntry.day,
                  dateOfEntry.hour,
                  dateOfEntry.minute,
                ));
              }

              // String formattedDate =
              //     DateFormat('h:mm a MMMM d, y').format(DateTime(
              //   dateOfEntry.year,
              //   dateOfEntry.month,
              //   dateOfEntry.day,
              //   dateOfEntry.hour,
              //   dateOfEntry.minute,
              // ));

              Color color = Theme.of(context).colorScheme.secondaryContainer;
              Icon icon = Icon(
                Icons.check_circle_outline,
                size: 40,
              );

              if (summarizedEntry[2] == 'quarantined' || summarizedEntry[3]) {
                color = Theme.of(context).colorScheme.errorContainer;
                icon = Icon(Icons.warning_amber_rounded, size: 40);
              }

              return Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Card(
                  color: color,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 2),
                    child: ListTile(
                      leading: icon,
                      title: Text(
                        formattedDate,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        remarks,
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
        });
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

  List _summarizeEntry(Entry? entry) {
    Map<String, dynamic> packagedEntry = {};
    packagedEntry
      ..addAll(entry!.fluSymptoms)
      ..addAll(entry.respiratorySymptoms)
      ..addAll(entry.otherSymptoms);
    packagedEntry['Exposure Report'] = entry.exposureReport;

    var exposureStatus = false;
    var status = "cleared";

    if (packagedEntry['Exposure Report']!) {
      exposureStatus = true;
    }

    for (var key in packagedEntry.keys) {
      if (key == 'Exposure Report' || key == 'None') {
        continue;
      }

      if (packagedEntry[key]) {
        status = "quarantined";
      }
    }

    var returnValues = [];
    if (status == "quarantined") {
      returnValues.add("Has symptoms");
    } else {
      returnValues.add("No symptoms");
    }
    if (exposureStatus) {
      returnValues
          .add("Has face-to-face encounter with a confirmed COVID-19 case");
    } else {
      returnValues
          .add("No face-to-face encounter with a confirmed COVID-19 case");
    }

    returnValues
      ..add(status)
      ..add(exposureStatus);

    return returnValues;
  }
}

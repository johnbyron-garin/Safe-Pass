import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:safe_pass/screens/misc/SideDrawer.dart';
import '../../models/entry_model.dart';
import '../../providers/entry_provider.dart';
import '../../styles.dart';

class EntryHistory extends StatelessWidget {
  EntryHistory({super.key});

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot<Map<String, dynamic>>> recentEntriesStream =
        context.watch<EntryProvider>().fetchUserEntries(context);

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
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Scaffold(
              appBar: AppBar(),
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: ListView(scrollDirection: Axis.vertical, children: [
                  Text(
                    "Entry History",
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _noEntryYet(context),
                ]),
              ),
          );
        }

          List entries = snapshot.data!.docs;

          return Scaffold(
            appBar: AppBar(),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: ListView(scrollDirection: Axis.vertical, children: [
                Text(
                  "Entry History",
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: _buildEntryList(context, entries),
                ),
              ]),
            ),
          );
        });
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
                "No entries yet.",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Submit one via the Add button in Home.",
                  style: TextStyle(fontWeight: FontWeight.w300))),
        ),
      ),
    );
  }

  Widget _buildEntryList(BuildContext context, List entries) {
    return Column(
      children: entries.map<Padding>((var value) {
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

        String formattedDate = DateFormat('h:mm a MMMM d, y').format(DateTime(
          dateOfEntry!.year,
          dateOfEntry.month,
          dateOfEntry.day,
          dateOfEntry.hour,
          dateOfEntry.minute,
        ));

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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe_pass/screens/user/edit_entry.dart';

import '../../models/account_model.dart';
import '../../models/entry_model.dart';
import '../../models/entry_request_model.dart';
import '../../providers/account_provider.dart';
import '../../providers/entry_provider.dart';
import '../../providers/entry_request_provider.dart';
import '../../providers/time_provider.dart';

class TodaysEntry extends StatefulWidget {
  const TodaysEntry({super.key});

  @override
  _TodaysEntryState createState() => _TodaysEntryState();
}

class _TodaysEntryState extends State<TodaysEntry> {
  var _hasEntry;
  var _userUID;
  Entry? _currentEntry;
  TextEditingController _reasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    DocumentReference<Map<String, dynamic>> userStream =
        context.watch<AccountProvider>().userAccount;

    return StreamBuilder<DocumentSnapshot>(
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
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
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
          _userUID = data['id'];

          print("${data} + @@@@");

          return FutureBuilder<Entry?>(
              future: setHasEntry(data['latestEntry'],
                  context.read<EntryProvider>(), context.read<TimeProvider>()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Scaffold(
                    appBar: AppBar(),
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                _currentEntry = snapshot.data;
                return _todaysEntryScaffold(
                    Account.fromJson(data), snapshot.data);
              });

          // return _homeBody(Account.fromJson(data));
        });
  }

  Widget _todaysEntryScaffold(Account account, Entry? entry) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: ListView(
          children: [_title(), _hasEntry ? _form(entry) : _noEntry()],
        ),
      ),
      bottomNavigationBar: _bottomNavBarWrapper(account, entry),
    );
  }

  Widget? _bottomNavBarWrapper(Account account, Entry? entry) {
    if (_hasEntry) {
      if (entry!.forApproval!) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 18),
          child: Text(
            "You have already submitted an entry modification request.",
            style: TextStyle(fontWeight: FontWeight.w300),
            textAlign: TextAlign.center,
          ),
        );
      } else {
        return _bottomButtons(account, entry);
      }
    } else {
      return null;
    }
  }

  Widget _noEntry() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "No entry submitted for today.",
          style: TextStyle(fontWeight: FontWeight.w300, fontSize: 20),
        ),
        _noteCard()
      ],
    );
  }

  Widget _noteCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
                "Note",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Add your daily entry via the Add button on Home.",
                  style: TextStyle(fontWeight: FontWeight.w300))),
        ),
      ),
    );
  }

  Widget _bottomButtons(Account account, Entry? entry) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                            Theme.of(context).colorScheme.primaryContainer)),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EditEntry(
                            userUID: _userUID,
                            oldEntryID: _currentEntry!.id,
                            studentName: account.name,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      "Edit",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                            Theme.of(context).colorScheme.errorContainer)),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Delete entry?"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: _reasonController,
                                  decoration: InputDecoration(
                                      hintText: "Reason for deletion",
                                      border: OutlineInputBorder()),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: const Text(
                                      "It is subject for approval of an admin.",
                                      textAlign: TextAlign.center,),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  EntryRequest newEntry = EntryRequest(
                                      studentName: account.name,
                                      oldEntryID: entry!.id!,
                                      requestType: "delete",
                                      userUID: account.id!,
                                      reason: _reasonController.text,
                                      status: "pending");

                                  showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text("Submitting entry"),
                                        content: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            CircularProgressIndicator(),
                                          ],
                                        ),
                                      );
                                    },
                                  );

                                  var documentID = await context
                                      .read<EntryRequestProvider>()
                                      .addRequest(newEntry);
                                  await context
                                      .read<EntryProvider>()
                                      .setForApproval(entry.id, true);

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(
                                          "Entry modification request submitted. Wait for an admin to take an action."),
                                    ));
                                    Navigator.of(context)
                                        .popUntil(ModalRoute.withName('/home'));
                                  }
                                },
                                child: Text(
                                  "Delete",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onErrorContainer),
                                ),
                              )
                            ],
                          );
                        },
                      );
                    },
                    child: Text("Delete",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _title() {
    return Text(
      "Today's Entry",
      style: TextStyle(
        fontSize: 42,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _form(Entry? entry) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Symptoms",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: _fluSymptomsForm(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: _respiratorySymptomsForm(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: _otherSymptomsForm(),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(),
          ),
          Text(
            "Exposure Report",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          _exposureReportForm()
        ],
      ),
    );
  }

  Widget _fluSymptomsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Flu-like Symptoms",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          textAlign: TextAlign.start,
        ),
        _buildFluSymptomsCheckbox()
      ],
    );
  }

  Widget _buildFluSymptomsCheckbox() {
    return Column(
      children: _currentEntry!.fluSymptoms.keys.map((key) {
        if (key == "None") {
          return CheckboxListTile(
              title: Text(
                key,
                style: TextStyle(fontWeight: FontWeight.w300),
              ),
              value: _currentEntry!.fluSymptoms[key],
              onChanged: null);
        } else {
          return CheckboxListTile(
              title: Text(key, style: TextStyle(fontWeight: FontWeight.w300)),
              value: _currentEntry!.fluSymptoms[key],
              onChanged: null);
        }
      }).toList(),
    );
  }

  Widget _respiratorySymptomsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Respiratory Symptoms",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          textAlign: TextAlign.start,
        ),
        _buildRespiratorySymptomsCheckbox()
      ],
    );
  }

  Widget _buildRespiratorySymptomsCheckbox() {
    return Column(
      children: _currentEntry!.respiratorySymptoms.keys.map((key) {
        if (key == "None") {
          return CheckboxListTile(
              title: Text(key, style: TextStyle(fontWeight: FontWeight.w300)),
              value: _currentEntry!.respiratorySymptoms[key],
              onChanged: null);
        } else {
          return CheckboxListTile(
              title: Text(key, style: TextStyle(fontWeight: FontWeight.w300)),
              value: _currentEntry!.respiratorySymptoms[key],
              onChanged: null);
        }
      }).toList(),
    );
  }

  Widget _otherSymptomsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Other Symptoms",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          textAlign: TextAlign.start,
        ),
        _buildOtherSymptomsCheckbox()
      ],
    );
  }

  Widget _buildOtherSymptomsCheckbox() {
    return Column(
      children: _currentEntry!.otherSymptoms.keys.map((key) {
        if (key == "None") {
          return CheckboxListTile(
              title: Text(key, style: TextStyle(fontWeight: FontWeight.w300)),
              value: _currentEntry!.otherSymptoms[key],
              onChanged: null);
        } else {
          return CheckboxListTile(
              title: Text(key, style: TextStyle(fontWeight: FontWeight.w300)),
              value: _currentEntry!.otherSymptoms[key],
              onChanged: null);
        }
      }).toList(),
    );
  }

  Widget _exposureReportForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            "Did you have a face-to-face encounter or contact with a confirmed COVID-19 case within 1 meter and for more than 15 minutes; or direct care for a patient with a probable or confirmed COVID-19 case?",
            style: TextStyle(fontWeight: FontWeight.w300, fontSize: 16),
            textAlign: TextAlign.start,
          ),
        ),
        _buildExposureReportRadio()
      ],
    );
  }

  Widget _buildExposureReportRadio() {
    return Column(
      children: [
        RadioListTile(
            title: Text("Yes"),
            value: true,
            groupValue: _currentEntry!.exposureReport,
            onChanged: null),
        RadioListTile(
            title: Text("No"),
            value: false,
            groupValue: _currentEntry!.exposureReport,
            onChanged: null),
      ],
    );
  }

  Future<Entry?> setHasEntry(
    String? entryID,
    EntryProvider entryProvider,
    TimeProvider timeProvider,
  ) async {
    if (entryID == null || entryID == "") {
      _hasEntry = false;
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
      _hasEntry = true;
    } else {
      _hasEntry = false;
    }

    return entry;
  }
}

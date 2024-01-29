import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe_pass/providers/account_provider.dart';
import '../../models/entry_model.dart';
import '../../providers/entry_provider.dart';
import 'generate_buildingpass.dart';

class AddEntry extends StatefulWidget {
  var userID;
  AddEntry({super.key, required this.userID});

  _AddEntryState createState() => _AddEntryState();
}

class _AddEntryState extends State<AddEntry> {
  var _fluLikeSymptoms = {
    'None': false,
    'Feeling feverish': false,
    'Muscle or Joint Pains': false
  };

  var _respiratorySymptoms = {
    'None': false,
    'Cough': false,
    'Colds': false,
    'Sore Throat': false,
    'Difficulty of Breathing': false,
  };

  var _otherSymptoms = {
    'None': false,
    'Diarrhea': false,
    'Loss of Taste': false,
    'Loss of Smell': false
  };

  // TODO: Validate checkbox
  // Validate everything
  var _exposureReport = null;

  // Validation boolean
  var isFluSymptomsInvalid = false;
  var isRespiratorySymptomsInvalid = false;
  var isOtherSymptomsInvalid = false;
  var isExposureReportInvalid = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: ListView(
          children: [
            _title(),
            _noteCard(),
            _form(),
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(
                              Theme.of(context).colorScheme.primaryContainer)),
                      onPressed: () async {
                        if (validate()) {
                          Entry newEntry = Entry(
                            fluSymptoms: _fluLikeSymptoms,
                            respiratorySymptoms: _respiratorySymptoms,
                            otherSymptoms: _otherSymptoms,
                            exposureReport: _exposureReport,
                            userUID: widget.userID,
                            forApproval: false,
                          );

                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Submitting entry"),
                                content: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    CircularProgressIndicator(),
                                  ],
                                ),
                              );
                            },
                          );

                          var documentID = await context
                              .read<EntryProvider>()
                              .addEntry(newEntry);
                          context
                              .read<AccountProvider>()
                              .setLatestEntry(widget.userID, documentID);
                          var ent = await context.read<EntryProvider>().getEntry(documentID!);

                          if (context.mounted) {
                            Navigator.of(context).pop();
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: ((context) => GenerateBuildingPass(
                                      entry: _packageEntryForQR(),
                                      documentID: documentID!,
                                      exitToHome: true,
                                      userUID: widget.userID,
                                      dateIssued: ent!.dateIssued,
                                    )));
                          }
                        } else {
                          print("form is invalid");
                        }
                      },
                      child: Text("Submit",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _title() {
    return const Text(
      "Add an entry",
      style: TextStyle(
        fontSize: 42,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _noteCard() {
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
                "Note",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                  "This should be accomplished daily and shall cover declarations and/or symptoms from your last entry in SafePass.",
                  style: TextStyle(fontWeight: FontWeight.w300))),
        ),
      ),
    );
  }

  Widget _form() {
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
        if (isFluSymptomsInvalid)
          Text(
            "This field is required.",
            style: TextStyle(
                fontWeight: FontWeight.w300,
                color: Theme.of(context).colorScheme.onErrorContainer),
          ),
        _buildFluSymptomsCheckbox()
      ],
    );
  }

  Widget _buildFluSymptomsCheckbox() {
    return Column(
      children: _fluLikeSymptoms.keys.map((key) {
        if (key == "None") {
          return CheckboxListTile(
            title: Text(
              key,
              style: TextStyle(fontWeight: FontWeight.w300),
            ),
            value: _fluLikeSymptoms[key],
            onChanged: (value) {
              setState(() {
                _fluLikeSymptoms[key] = value!;
                _fluLikeSymptoms.forEach((key, value) {
                  if (key != 'None') {
                    _fluLikeSymptoms[key] = false;
                  }
                });
              });
            },
          );
        } else {
          return CheckboxListTile(
            title: Text(key, style: TextStyle(fontWeight: FontWeight.w300)),
            value: _fluLikeSymptoms[key],
            onChanged: _fluLikeSymptoms['None']!
                ? null
                : (value) {
                    setState(() {
                      _fluLikeSymptoms[key] = value!;
                    });
                  },
          );
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
        if (isRespiratorySymptomsInvalid)
          Text(
            "This field is required.",
            style: TextStyle(
                fontWeight: FontWeight.w300,
                color: Theme.of(context).colorScheme.onErrorContainer),
          ),
        _buildRespiratorySymptomsCheckbox()
      ],
    );
  }

  Widget _buildRespiratorySymptomsCheckbox() {
    return Column(
      children: _respiratorySymptoms.keys.map((key) {
        if (key == "None") {
          return CheckboxListTile(
            title: Text(key, style: TextStyle(fontWeight: FontWeight.w300)),
            value: _respiratorySymptoms[key],
            onChanged: (value) {
              setState(() {
                _respiratorySymptoms[key] = value!;
                _respiratorySymptoms.forEach((key, value) {
                  if (key != 'None') {
                    _respiratorySymptoms[key] = false;
                  }
                });
              });
            },
          );
        } else {
          return CheckboxListTile(
            title: Text(key, style: TextStyle(fontWeight: FontWeight.w300)),
            value: _respiratorySymptoms[key],
            onChanged: _respiratorySymptoms['None']!
                ? null
                : (value) {
                    setState(() {
                      _respiratorySymptoms[key] = value!;
                    });
                  },
          );
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
        if (isOtherSymptomsInvalid)
          Text(
            "This field is required.",
            style: TextStyle(
                fontWeight: FontWeight.w300,
                color: Theme.of(context).colorScheme.onErrorContainer),
          ),
        _buildOtherSymptomsCheckbox()
      ],
    );
  }

  Widget _buildOtherSymptomsCheckbox() {
    return Column(
      children: _otherSymptoms.keys.map((key) {
        if (key == "None") {
          return CheckboxListTile(
            title: Text(key, style: TextStyle(fontWeight: FontWeight.w300)),
            value: _otherSymptoms[key],
            onChanged: (value) {
              setState(() {
                _otherSymptoms[key] = value!;
                _otherSymptoms.forEach((key, value) {
                  if (key != 'None') {
                    _otherSymptoms[key] = false;
                  }
                });
              });
            },
          );
        } else {
          return CheckboxListTile(
            title: Text(key, style: TextStyle(fontWeight: FontWeight.w300)),
            value: _otherSymptoms[key],
            onChanged: _otherSymptoms['None']!
                ? null
                : (value) {
                    setState(() {
                      _otherSymptoms[key] = value!;
                    });
                  },
          );
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
        if (isExposureReportInvalid)
          Text(
            "This field is required.",
            style: TextStyle(
                fontWeight: FontWeight.w300,
                color: Theme.of(context).colorScheme.onErrorContainer),
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
          groupValue: _exposureReport,
          onChanged: (value) {
            setState(() {
              _exposureReport = value!;
            });
          },
        ),
        RadioListTile(
          title: Text("No"),
          value: false,
          groupValue: _exposureReport,
          onChanged: (value) {
            setState(() {
              _exposureReport = value!;
            });
          },
        ),
      ],
    );
  }

  bool validate() {
    if (!_fluLikeSymptoms.values.any((value) => value == true)) {
      setState(() {
        isFluSymptomsInvalid = true;
      });
    } else {
      setState(() {
        isFluSymptomsInvalid = false;
      });
    }

    if (!_respiratorySymptoms.values.any((value) => value == true)) {
      setState(() {
        isRespiratorySymptomsInvalid = true;
      });
    } else {
      setState(() {
        isRespiratorySymptomsInvalid = false;
      });
    }

    if (!_otherSymptoms.values.any((value) => value == true)) {
      setState(() {
        isOtherSymptomsInvalid = true;
      });
    } else {
      setState(() {
        isOtherSymptomsInvalid = false;
      });
    }

    if (_exposureReport == null) {
      setState(() {
        isExposureReportInvalid = true;
      });
    } else {
      setState(() {
        isExposureReportInvalid = false;
      });
    }

    // print(
    //     "flu $isFluSymptomsInvalid\nresp $isRespiratorySymptomsInvalid\noth $isOtherSymptomsInvalid\nexp$isExposureReportInvalid");

    if (isFluSymptomsInvalid ||
        isRespiratorySymptomsInvalid ||
        isOtherSymptomsInvalid ||
        isExposureReportInvalid) {
      return false;
    }

    return true;
  }

  Map<String, bool> _packageEntryForQR() {
    Map<String, bool> entry = {};
    entry
      ..addAll(_fluLikeSymptoms)
      ..addAll(_respiratorySymptoms)
      ..addAll(_otherSymptoms);
    entry['Exposure Report'] = _exposureReport;

    return entry;
  }
}

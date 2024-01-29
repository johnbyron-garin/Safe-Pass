import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:safe_pass/providers/account_provider.dart';

class GenerateBuildingPass extends StatelessWidget {
  Map<String, dynamic> entry;
  bool exitToHome;
  String? documentID;
  String? userUID;
  DateTime? dateIssued;
  GenerateBuildingPass(
      {super.key,
      required this.entry,
      required this.exitToHome,
      required this.documentID,
      required this.userUID,
      this.dateIssued});

  var status;

  @override
  Widget build(BuildContext context) {
    return _buildingPassDialogWrapper(context);
  }

  Widget _buildingPassDialogWrapper(BuildContext context) {
    status = _checkEntry();

    if (exitToHome) {
      context.read<AccountProvider>().setStatus(userUID, status);
    }

    if (status == "cleared") {
      return _clearedWithQRCode(context);
    } else {
      return _noBuildingPass(context);
    }
  }

  String _checkEntry() {
    var status = "cleared";

    if (entry['Exposure Report']!) {
      status = "monitoring";
    }

    for (var key in entry.keys) {
      if (key == 'Exposure Report' || key == 'None') {
        continue;
      }

      if (entry[key]!) {
        status = "quarantined";
        break;
      }
    }

    return status;
  }

  Widget _clearedWithQRCode(BuildContext context) {
    String formattedDate = DateFormat('h:mm a MMMM d, y').format(DateTime(
      dateIssued!.year,
      dateIssued!.month,
      dateIssued!.day,
      dateIssued!.hour,
      dateIssued!.minute,
    ));
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline_outlined,
              size: 50,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Building Pass Generated!",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                textAlign: TextAlign.center,
              ),
            ),
            _generateQR(context),
            Text(
              formattedDate,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            Opacity(
              opacity: 0.4,
              child: Divider(color: Theme.of(context).colorScheme.onSurface),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "Present this QR code to the Entrance Monitor.",
                style: TextStyle(fontWeight: FontWeight.w300, fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "You could also retrieve this QR code in your Profile's screen.",
                style: TextStyle(fontWeight: FontWeight.w300),
                textAlign: TextAlign.center,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(
                          Theme.of(context).colorScheme.onSurface),
                    ),
                    onPressed: () {
                      if (exitToHome) {
                        Navigator.of(context)
                            .popUntil(ModalRoute.withName('/home'));
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(
                      "Close",
                      style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.primaryContainer),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _generateQR(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        color: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        child: QrImage(
          data: documentID!,
          version: QrVersions.auto,
          size: 180,
        ),
      ),
    );
  }

  Widget _noBuildingPass(BuildContext context) {
    var titleText;
    var subTitle;

    if (status == "quarantined") {
      titleText = "You are advised to undergo quarantine.";
      subTitle = "Please follow UHS' quarantine guideline.";
    } else if (status == "monitoring") {
      titleText = "You are advised to undergo monitoring.";
      subTitle = "Please follow UHS' monitoring guideline.";
    }

    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              titleText,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Center(
              child: _infoIcon(context),
            ),
            Text(
              subTitle,
              style: TextStyle(fontWeight: FontWeight.w300, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            Flexible(
              fit: FlexFit.loose,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  "Made a mistake? Edit your entry in Today's Entry page. It is however to be subjected for approval of an admin.",
                  style: TextStyle(fontWeight: FontWeight.w300),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(
                          Theme.of(context).colorScheme.onSurface),
                    ),
                    onPressed: () {
                      if (exitToHome) {
                        Navigator.of(context)
                            .popUntil(ModalRoute.withName('/home'));
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(
                      "Close",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.errorContainer),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _infoIcon(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 35),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
              width: 2, color: Theme.of(context).colorScheme.onBackground),
        ),
        child: Icon(
          Icons.priority_high_rounded,
          weight: 4,
          size: 60,
        ),
      ),
    );
  }
}

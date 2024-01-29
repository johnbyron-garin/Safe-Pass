import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:safe_pass/models/buildinglog_model.dart';
import 'package:safe_pass/providers/building_log_provider.dart';
import 'package:safe_pass/providers/entry_provider.dart';
import 'package:safe_pass/providers/time_provider.dart';
import 'package:safe_pass/screens/user/generate_buildingpass.dart';

import '../../models/account_model.dart';
import '../../models/entry_model.dart';
import '../../providers/account_provider.dart';
import '../../styles.dart';
import '../misc/SideDrawer.dart';

import 'package:mobile_scanner/mobile_scanner.dart';

class ScanScreen extends StatefulWidget {
  ScanScreen({super.key});
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  MobileScannerController cameraController = MobileScannerController();

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
          return Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(
                  icon: ValueListenableBuilder(
                    valueListenable: cameraController.cameraFacingState,
                    builder: (context, state, child) {
                      switch (state as CameraFacing) {
                        case CameraFacing.front:
                          return const Icon(Icons.camera_front_rounded);
                        case CameraFacing.back:
                          return const Icon(Icons.camera_rear_rounded);
                      }
                    },
                  ),
                  onPressed: () => cameraController.switchCamera(),
                )
              ],
            ),
            body: FutureBuilder<DateTime?>(
              future: context.read<TimeProvider>().getTime(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return _body(Account.fromJson(data), snapshot.data!);
              },
            ),
          );
        });
  }

  MobileScanner _body(Account account, DateTime? serverTime) {
    return MobileScanner(
      controller: cameraController,
      onDetect: (capture) {
        List<Barcode> barcodes = capture.barcodes;
        cameraController.stop();

        _verifyID(
            barcodes.first.rawValue,
            account,
            serverTime,
            context.read<AccountProvider>(),
            context.read<BuildingLogProvider>());
      },
    );
  }

  void _verifyID(
      String? entryID,
      Account acc,
      DateTime? serverTime,
      AccountProvider accountProvider,
      BuildingLogProvider buildingLogProvider) async {
    final currentContext = context;

    showDialog(
        barrierDismissible: false,
        context: currentContext,
        builder: (context) {
          return const AlertDialog(
              title: Text("Verifying Building Pass"),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                ],
              ));
        });

    final entry = await currentContext.read<EntryProvider>().getEntry(entryID!);

    if (currentContext.mounted) {
      if (entry == null) {
        Navigator.of(currentContext).pop();
        _qrCodeResult(currentContext, "404", null, null);
        return;
      }

      final user = await accountProvider.getAccountByID(entry.userUID!);
      if (currentContext.mounted) {
        var currentServerTimeDateOnly = DateTime(
          serverTime!.year,
          serverTime.month,
          serverTime.day,
        );

        var entryDateIssued = entry.dateIssued;
        var entryDate = DateTime(
          entryDateIssued!.year,
          entryDateIssued.month,
          entryDateIssued.day,
        );

        if (currentServerTimeDateOnly == entryDate) {
          var uid = await buildingLogProvider.addBuildingLog(BuildingLog(
              entryDocumentID: entry.id,
              userUID: user!.id,
              employeeUID: acc.id,
              studentName: user.name,
              homeUnit: acc.homeUnit));

          if (currentContext.mounted) {
            Navigator.of(currentContext).pop();
            showDialog(
              barrierDismissible: false,
              context: currentContext,
              builder: (context) {
                return _qrCodeResult(currentContext, "success", user, entry);
              },
            );
          }
        } else {
          Navigator.of(currentContext).pop();
          showDialog(
            barrierDismissible: false,
            context: currentContext,
            builder: (context) {
              return _qrCodeResult(currentContext, "expired", user, entry);
            },
          );
        }
      }
    }
  }

  Widget _qrCodeResult(
      BuildContext context, String? scanResult, Account? acc, Entry? ent) {
    if (scanResult == "success") {
      var dateOfEntry = ent!.dateIssued;

      String formattedDate = DateFormat('h:mm a MMMM d, y').format(DateTime(
        dateOfEntry!.year,
        dateOfEntry.month,
        dateOfEntry.day,
        dateOfEntry.hour,
        dateOfEntry.minute,
      ));

      return Dialog(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Building Pass Verified!",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Icon(
                    Icons.check_circle_outline_outlined,
                    size: 80,
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              "Student Name:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              acc!.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              "Date Issued:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Student added to building log.",
                            style: TextStyle(
                              fontWeight: FontWeight.w300,
                            ),
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
                                Navigator.of(context).pop();
                                cameraController.start();
                              },
                              child: Text(
                                "Close",
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer),
                              ),
                            ),
                          )
                        ],
                      )
                    ]))
              ]),
        ),
      );
    } else if (scanResult == "404") {
      return Dialog(
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Invalid Building Pass",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Icon(
                  Icons.cancel_outlined,
                  size: 80,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "SafePass wasn't able to verify the authenticity of the building pass scanned",
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "This is usually caused by a malformed QR Code, or an invalid QR Code being scanned",
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                  ),
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
                        Navigator.of(context).pop();
                        cameraController.start();
                      },
                      child: Text(
                        "Close",
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.errorContainer),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      );
    } else {
      return Dialog(
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Invalid Building Pass",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                  textAlign: TextAlign.center,
                ),
              ),
              Icon(
                Icons.cancel_outlined,
                size: 80,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Student Name:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "The scanned building pass is expired. Kindly request the student to generate a new one",
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
                        Navigator.of(context).pop();
                        cameraController.start();
                      },
                      child: Text(
                        "Close",
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.errorContainer),
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
  }

  // @override
  // Widget build(BuildContext context) {
  //   return _qrCodeResult(context);
  // }
}

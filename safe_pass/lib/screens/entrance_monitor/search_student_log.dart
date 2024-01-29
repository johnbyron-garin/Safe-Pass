import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:safe_pass/providers/building_log_provider.dart';
import 'package:safe_pass/screens/entrance_monitor/scan_screen.dart';
import 'package:safe_pass/screens/misc/SideDrawer.dart';
import 'package:safe_pass/screens/user/generate_buildingpass.dart';

import '../../models/account_model.dart';
import '../../models/buildinglog_model.dart';
import '../../providers/account_provider.dart';
import '../../styles.dart';
import '../misc/monitor_sideDrawer.dart';

class SearchStudentLog extends StatefulWidget {
  const SearchStudentLog({super.key});
  @override
  _SearchStudentLogState createState() => _SearchStudentLogState();
}

class _SearchStudentLogState extends State<SearchStudentLog> {
  final TextEditingController _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSearching = false;

  /**
   * To do:
   *  - implement search button/feature
   */

  Widget _SearchStudentLogContainer() {
    return Text(
      "Building Logs",
      style: TextStyle(
        fontSize: 42,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _SearchBar() {
    return Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TextFormField(
                controller: _searchController,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: "Search",
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        setState(() {});
                      },
                    )),
                onEditingComplete: () {
                  setState(() {});
                },
              ),
            ),
          ],
        ));
  }

  Widget _recentEntryList(BuildContext context, Account account) {
    Stream<QuerySnapshot<Map<String, dynamic>>> buildingLogStream = context
        .watch<BuildingLogProvider>()
        .getLogsByHomeUnit(account.homeUnit);

    return StreamBuilder(
      stream: buildingLogStream,
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
          return _noEntryYet(context);
        }

        List logs = snapshot.data!.docs;

        if (_searchController.text.isNotEmpty || _searchController.text != "") {
          logs = logs.where((element) {
            var log =
                BuildingLog.fromJson(element.data() as Map<String, dynamic>);
            return log.studentName!
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());
          }).toList();
        }

        return Column(
          children: logs.map<Padding>((var value) {
            Color color = Theme.of(context).colorScheme.secondaryContainer;
            Icon icon = Icon(
              Icons.check_circle_outline,
              size: 40,
            );

            var log =
                BuildingLog.fromJson(value.data() as Map<String, dynamic>);
            var dateScanned = log.dateScanned;

            String formattedDate =
                DateFormat('h:mm a MMMM d, y').format(DateTime(
              dateScanned!.year,
              dateScanned.month,
              dateScanned.day,
              dateScanned.hour,
              dateScanned.minute,
            ));

            return Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Card(
                color: color,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  child: ListTile(
                    leading: icon,
                    title: Text(
                      log.studentName!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      formattedDate,
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
      },
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

        print("${data} + @@@@");
        return _buildingLogScaffold(Account.fromJson(data));
      },
    );
  }

  Widget _buildingLogScaffold(Account account) {
    return Scaffold(
      appBar: AppBar(),
      drawer:
          Builder(builder: (context) => SideDrawer(status: account.userType)),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        children: <Widget>[
          _SearchStudentLogContainer(),
          _SearchBar(),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: const Divider(),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text("Recent Entries",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                )),
          ),
          _recentEntryList(context, account),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // showDialog(
          //     context: context,
          //     barrierDismissible: true,
          //     builder: ((context) => ScanScreen()));
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => ScanScreen()));
        },
        child: const Icon(Icons.qr_code_scanner),
      ),
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
                "No logs yet.",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Scan an entry using the Scan button.",
                  style: TextStyle(fontWeight: FontWeight.w300))),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class SideDrawer extends StatelessWidget {
  String? status;
  SideDrawer({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      children: _getDrawerItems(context, status),
    ));
  }

  Widget _headerDrawer() {
    var currentHour = DateTime.now().hour;
    var greeting = "";

    if (currentHour >= 6 && currentHour < 12) {
      greeting = "⛅️\nGood Morning!";
    } else if (currentHour >= 12 && currentHour < 18) {
      greeting = "☀️\nGood Afternoon!";
    } else if (currentHour >= 18 || currentHour < 6) {
      greeting = "🌙\nGood Evening!";
    }

    return DrawerHeader(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
          ),
          Text(
            "Navigate SafePass through this drawer.",
            style: TextStyle(fontWeight: FontWeight.w300, fontSize: 12),
          )
        ],
      ),
    );
  }

  List<Widget> _studentNav(BuildContext context) {
    return [
      ListTile(
        title: const Text(
          "Home",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        leading: Icon(Icons.home_outlined),
        onTap: () {
          navigateTo(context, '/home');
        },
      ),
      ListTile(
        title: const Text("Profile",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        leading: Icon(Icons.account_circle_outlined),
        onTap: () {
          navigateTo(context, '/mainprofile');
        },
      ),
      ListTile(
        title: const Text("Today's Entry",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        leading: Icon(Icons.fact_check_outlined),
        onTap: () {
          navigateTo(context, '/todays-entry');
        },
      ),
      ListTile(
        title: const Text("Entry History",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        leading: Icon(Icons.history_outlined),
        onTap: () {
          navigateTo(context, '/entry-history');
        },
      ),
    ];
  }

  List<Widget> _entranceMonitorNav(BuildContext context) {
    return [
      const Divider(),
      ListTile(
        title: const Text(
          "Scan a QR",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        leading: Icon(Icons.qr_code_scanner_rounded),
        onTap: () {
          navigateTo(context, '/scan-screen');
        },
      ),
      ListTile(
        title: const Text("View Building Logs",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        leading: Icon(Icons.home_work_rounded),
        onTap: () {
          navigateTo(context, '/search-student-log');
        },
      ),
    ];
  }

  List<Widget> _adminNav(BuildContext context) {
    return [
      const Divider(),
      ListTile(
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        leading: Icon(Icons.dashboard),
        onTap: () {
          navigateTo(context, '/admin-dashboard');
        },
      ),
      ListTile(
        title: const Text(
          "Students",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        leading: Icon(Icons.people),
        onTap: () {
          navigateTo(context, '/student-list');
        },
      ),
      ListTile(
        title: const Text(
          "Monitored Students",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        leading: Icon(Icons.remove_red_eye),
        onTap: () {
          navigateTo(context, '/under-monitoring');
        },
      ),
      ListTile(
        title: const Text(
          "Quarantined Students",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        leading: Icon(Icons.warning),
        onTap: () {
          navigateTo(context, '/under-quarantine');
        },
      ),
      ListTile(
        title: const Text(
          "Pending Requests",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        leading: Icon(Icons.pending),
        onTap: () {
          navigateTo(context, '/pending-requests');
        },
      ),
    ];
  }

  List<Widget> _signOut(BuildContext context) {
    return [
      const Divider(),
      ListTile(
        title: Text("Sign Out",
            style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        leading: Icon(Icons.logout_outlined),
        onTap: () {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Signing out."),
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(),
                  ],
                ),
              );
            },
          );
          context.read<AuthProvider>().signOut();

          if (context.mounted) {
            Navigator.popUntil(context, ModalRoute.withName('/home'));
            Navigator.pushReplacementNamed(context, '/');
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Signed out successfully."),
            ));
          }
        },
      )
    ];
  }

  List<Widget> _getDrawerItems(BuildContext context, String? status) {
    var drawerItems = <Widget>[];
    drawerItems.add(_headerDrawer());

    if (status == "student" ||
        status == "entrance_monitor" ||
        status == "admin") {
      drawerItems.addAll(_studentNav(context));
    }

    if (status == "entrance_monitor") {
      drawerItems.addAll(_entranceMonitorNav(context));
    }

    if (status == "admin") {
      drawerItems.addAll(_adminNav(context));
    }

    drawerItems.addAll(_signOut(context));

    return drawerItems;
  }

  void navigateTo(BuildContext context, String route) {
    Navigator.pop(context);

    if (ModalRoute.of(context)?.settings.name != route) {
      if (ModalRoute.of(context)?.settings.name == '/home') {
        Navigator.pushNamed(context, route);
      } else if (route == '/home') {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacementNamed(context, route);
      }
    }
  }
}

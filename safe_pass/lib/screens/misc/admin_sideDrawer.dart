import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class AdminSideDrawer extends StatelessWidget {
  const AdminSideDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    var allWidgets = concatenateLists(context);
    return Drawer(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: allWidgets.length,
        padding: EdgeInsets.zero,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: allWidgets[index],
          );
        },
      ),
    );
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

  List<Widget> _header() {
    var currentHour = DateTime.now().hour;
    var greeting = "";

    if (currentHour >= 6 && currentHour < 12) {
      greeting = "⛅️\nGood Morning!";
    } else if (currentHour >= 12 && currentHour < 18) {
      greeting = "☀️\nGood Afternoon!";
    } else if (currentHour >= 18 || currentHour < 6) {
      greeting = "🌙\nGood Evening!";
    }

    return <Widget>[
      Text(
        greeting,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
      ),
      Text(
        "Navigate SafePass through this drawer.",
        style: TextStyle(fontWeight: FontWeight.w300, fontSize: 12),
      )
    ];
  }

  List<Widget> _section1(BuildContext context) {
    return <Widget>[
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
      const Divider(),
    ];
  }

  List<Widget> _section2(BuildContext context) {
    return <Widget>[
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
        title: const Text("Students",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        leading: Icon(Icons.people),
        onTap: () {
          navigateTo(context, '/student-list');
        },
      ),
      ListTile(
        title: const Text("Monitored Students",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        leading: Icon(Icons.remove_red_eye),
        onTap: () {
          navigateTo(context, '/under-monitoring');
        },
      ),
      ListTile(
        title: const Text("Quarantined Students",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        leading: Icon(Icons.warning),
        onTap: () {
          navigateTo(context, '/under-quarantine');
        },
      ),
      ListTile(
        title: const Text("Pending Requests",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        leading: Icon(Icons.pending),
        onTap: () {
          navigateTo(context, '/pending-requests');
        },
      ),
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
      ),
    ];
  }

  List<Widget> concatenateLists(BuildContext context) {
    List<Widget> list0 = _header();
    List<Widget> list1 = _section1(context);
    List<Widget> list2 = _section2(context);

    return [...list0, ...list1, ...list2];
  }
}

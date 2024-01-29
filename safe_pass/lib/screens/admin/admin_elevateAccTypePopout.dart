import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/account_model.dart';
import '../../providers/account_provider.dart';

class ElevatePopout extends StatelessWidget {
  final Account account;
  ElevatePopout({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      // backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Elevate User to:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Icon(Icons.admin_panel_settings),
                  title: Text('Admin'),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: ((context) => _confirm(context, 'Admin')));
                    Navigator.pop(context);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Icon(Icons.security),
                  title: Text('Entrance Monitor'),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: ((context) =>
                            _confirm(context, 'Entrance Monitor')));
                  },
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
                      },
                      child: Text(
                        "Close",
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.primaryContainer),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _confirm(BuildContext context, String acc) {
    String type;

    if (acc == 'Admin')
      type = 'admin';
    else
      type = 'entrance_monitor';

    return AlertDialog(
      title: Text('Are you sure you want to elevate user to $acc?'),
      actions: <Widget>[
        TextButton(
          child: Text('Yes'),
          onPressed: () {
            context.read<AccountProvider>().elevateAccount(account.id, type);
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

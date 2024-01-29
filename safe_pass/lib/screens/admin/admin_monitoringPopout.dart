import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe_pass/models/account_model.dart';
import 'package:safe_pass/providers/admin_addToQuarantine_provider.dart';
import 'package:safe_pass/providers/admin_clear_status_provider.dart';

class MonitoringPopout extends StatelessWidget {
  Account student;
  MonitoringPopout({super.key, required this.student});

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
                  'Actions',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Icon(Icons.warning),
                  title: Text('Quarantine Student'),
                  onTap: () {
                    context.read<AddToQuarantineProvider>().addToQuarantine(student.id!);
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Icon(Icons.check_circle),
                  title: Text('End Monitoring'),
                  onTap: () {
                    context.read<ClearStatusProvider>().clearStatus(student.id!);
                    Navigator.of(context).pop();
                    
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
}

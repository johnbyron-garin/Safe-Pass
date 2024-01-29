import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe_pass/models/account_model.dart';
import 'package:safe_pass/providers/admin_clear_status_provider.dart';

class QuarantinePopout extends StatelessWidget {
  Account student;
  QuarantinePopout({super.key, required this.student});

  var studName = 'Juan Dela Cruz';
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Remove "$studName" from quarantine?'),
      actions: <Widget>[
        TextButton(
          child: Text('Remove'),
          onPressed: () {
            context.read<ClearStatusProvider>().clearStatus(student.id!);
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

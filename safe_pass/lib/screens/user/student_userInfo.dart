import 'package:flutter/material.dart';

import '../../models/account_model.dart';

class UserInformation extends StatelessWidget {
  final Account account;
  UserInformation({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Profile Info',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                ),
              ),
              _userIcon(context),
              _userInformation(),
              Opacity(
                opacity: 0.4,
                child: Divider(color: Theme.of(context).colorScheme.onSurface),
              ),
              _status(),
              Opacity(
                opacity: 0.4,
                child: Divider(color: Theme.of(context).colorScheme.onSurface),
              ),
              if (account.userType == "student") _preExistingIllness(),
              if (account.userType == "student") _allergies(),
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

  Widget _userIcon(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
            width: 2, color: Theme.of(context).colorScheme.onBackground),
      ),
      child: Icon(
        Icons.person,
        size: 40,
      ),
    );
  }

  Widget _userInformation() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            account.name,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ),
        Column(
          children: [
            Text(
              account.course == null ? account.position! : account.course!,
              style: TextStyle(fontWeight: FontWeight.w300),
              textAlign: TextAlign.center,
            ), //course
            Text(
              account.college == null ? account.homeUnit! : account.college!,
              style: TextStyle(fontWeight: FontWeight.w300),
              textAlign: TextAlign.center,
            ), //college
            Text(
              account.studentNumber == null
                  ? account.employeeNo!
                  : account.studentNumber!,
              style: TextStyle(fontWeight: FontWeight.w300),
              textAlign: TextAlign.center,
            ), //studentNumber
          ],
        ),
      ],
    );
  }

  Widget _status() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text('Status:'),
          Text(
            account.status,
            style: TextStyle(fontWeight: FontWeight.bold),
          ), //status
        ],
      ),
    );
  }

  Widget _preExistingIllness() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Pre-Existing Illnesses:',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Flexible(
            fit: FlexFit.loose,
            child: Text(
                account.preExistingIllness!.isEmpty
                    ? "None"
                    : account.preExistingIllness!,
                style: TextStyle(fontWeight: FontWeight.w300),
                textAlign: TextAlign.center),
          )
        ],
      ),
    );
  }

  Widget _allergies() {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Allergies',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Flexible(
            fit: FlexFit.loose,
            child: Text(
                account.allergies!.isEmpty ? "None" : account.allergies!,
                style: TextStyle(fontWeight: FontWeight.w300),
                textAlign: TextAlign.center),
          )
        ],
      ),
    );
  }
}

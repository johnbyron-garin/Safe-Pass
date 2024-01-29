import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe_pass/providers/auth_provider.dart';

import '../../models/account_model.dart';
import '../../providers/account_provider.dart';

class PreExistingIllness extends StatefulWidget {
  String email;
  String password;
  Account account;

  PreExistingIllness(
      {super.key,
      required this.email,
      required this.password,
      required this.account});

  @override
  _PreExistingIllnessState createState() => _PreExistingIllnessState();
}

class _PreExistingIllnessState extends State<PreExistingIllness> {
  TextEditingController _otherIllnessController = TextEditingController();
  TextEditingController _allergiesController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Map<String, bool> preexistingIllness = {
    'Hypertension': false,
    'Diabetes': false,
    'Tuberculosis': false,
    'Cancer': false,
    'Kidney Disease': false,
    'Cardiac Disease': false,
    'Autoimmune Disease': false,
    'Asthma': false,
  };

  var otherIllness = "";

  var allergies = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: ListView(scrollDirection: Axis.vertical, children: [
          _title(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: _buildCheckbox(),
          ),
          _otherIllnessTextField(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(),
          ),
          _allergiesTextField()
        ]),
      ),
    );
  }

  Widget _title() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Add your pre existing illness.",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Check all the ones that apply.",
            style: TextStyle(fontWeight: FontWeight.w300),
          )
        ],
      ),
    );
  }

  Widget _buildCheckbox() {
    return Column(
      children: preexistingIllness.keys.map((String key) {
        return CheckboxListTile(
          title: Text(key),
          value: preexistingIllness[key],
          onChanged: (value) {
            setState(() {
              preexistingIllness[key] = value!;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _otherIllnessTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Other illnesses (separate it with a comma): ",
          style: TextStyle(fontWeight: FontWeight.w300),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: TextField(
            controller: _otherIllnessController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Illness 1, Illness 2, ..."),
            minLines: 2,
            maxLines: null,
          ),
        )
      ],
    );
  }

  Widget _allergiesTextField() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Allergies",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const Text(
            "Enumerate your allergies below. Separate it with a comma.",
            style: TextStyle(fontWeight: FontWeight.w300),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14.0),
            child: TextFormField(
              controller: _allergiesController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Allergy 1,Allergy 2, ..."),
              minLines: 2,
              maxLines: null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 40),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: const ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll(Color(0xff087F8C)),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState?.save();
                        widget.account.allergies = _allergiesController.text;

                        var otherIllness = "";
                        if (_otherIllnessController.text.isNotEmpty) {
                          otherIllness = ","+ _otherIllnessController.text;
                        }
                        widget.account.preExistingIllness =
                            _getIllnesesString() + otherIllness;

                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Signing up"),
                              content: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  CircularProgressIndicator(),
                                ],
                              ),
                            );
                          },
                        );

                        var newUID = await context
                            .read<AuthProvider>()
                            .signUp(widget.email, widget.password);

                        if (context.mounted) {
                          switch (newUID) {
                            case "email-already-in-use":
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(
                                    "Account already exists. Try signing in instead."),
                              ));
                              break;
                            case "invalid-email":
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text("Invalid email."),
                              ));
                              break;
                            case "weak-password":
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text("Weak password."),
                              ));
                              break;
                            default:
                              context
                                  .read<AccountProvider>()
                                  .addAccount(widget.account, newUID!);
                              
                              Navigator.popUntil(
                                  context, ModalRoute.withName('/'));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(
                                    "Account successfuly created. You may now sign in."),
                              ));
                          }
                        }
                      }
                    },
                    child: const Text(
                      "Create Account",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  String _getIllnesesString() {
    // Gets the keys from illnesses that has a true value
    var illnessListString = preexistingIllness.entries
        .where((element) => element.value)
        .map((e) => e.key)
        .toList()
        .toString();
    return illnessListString.substring(1, illnessListString.length - 1);
  }
}

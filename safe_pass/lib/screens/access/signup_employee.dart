import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:safe_pass/screens/preexisting_illness.dart';
import 'package:safe_pass/styles.dart';

import '../../models/account_model.dart';
import '../../providers/account_provider.dart';
import '../../providers/auth_provider.dart';

class SignupEmployee extends StatefulWidget {
  String? userType;
  SignupEmployee({super.key, required this.userType});
  @override
  _SignupEmployeeState createState() => _SignupEmployeeState();
}

class _SignupEmployeeState extends State<SignupEmployee> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _employeeNumberController =
      TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _homeUnitController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // ignore: prefer_final_fields
  var _formValues = {
    'name': "",
    'employeeNo': "",
    'position': null,
    'homeUnit': null,
  };

  var _passwordVisible = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.only(left: 40.0, right: 40.0),
        children: <Widget>[
          _signUpContainer(),
          _signUpForm(),
        ],
      ),
    );
  }

  Widget _signUpContainer() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "Sign Up",
          style: Styles.titleTextStyle_Pass,
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            "As Employee",
            style: TextStyle(fontWeight: FontWeight.w300),
          ),
        )
      ],
    );
  }

  Widget _signUpForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter name",
                  labelText: "Name"),
              // Used onChanged insted of TextEditingController
              validator: (value) {
                // Value shouldnt be null or empty.
                if (value == null || value.isEmpty) {
                  return "Please enter your name.";
                }

                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TextFormField(
              controller: _employeeNumberController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter employee number",
                  labelText: "Employee number"),
              // Used onChanged insted of TextEditingController
              validator: (value) {
                // Value shouldnt be null or empty.
                if (value == null || value.isEmpty) {
                  return "Please enter your employee number";
                }

                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TextFormField(
              controller: _positionController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter your position",
                  labelText: "Position"),
              // Used onChanged insted of TextEditingController
              validator: (value) {
                // Value shouldnt be null or empty.
                if (value == null || value.isEmpty) {
                  return "Please enter your position.";
                }

                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TextFormField(
              controller: _homeUnitController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter home unit",
                  labelText: "Home Unit"),
              // Used onChanged insted of TextEditingController
              validator: (value) {
                // Value shouldnt be null or empty.
                if (value == null || value.isEmpty) {
                  return "Please enter your home unit.";
                }

                return null;
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter email",
                labelText: "Email",
              ),
              // Used onChanged insted of TextEditingController
              validator: (value) {
                // Value shouldnt be null or empty.
                if (value == null || value.isEmpty) {
                  return "Please enter your email";
                }

                if (!RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                    .hasMatch(_emailController.text)) {
                  return "Invalid email";
                }

                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TextFormField(
              controller: _passwordController,
              obscureText: !_passwordVisible,
              decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: "Enter password",
                  labelText: "Password",
                  helperText: "Password must be at least 6 characters.",
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  )),

              // Used onChanged insted of TextEditingController
              validator: (value) {
                // Value shouldnt be null or empty.
                if (value == null || value.isEmpty) {
                  return "Please enter your password";
                }

                if (_passwordController.text.length < 6) {
                  return "Password too short.";
                }

                return null;
              },
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
                        var newEmployeeAccount = Account(
                          userType: widget.userType!,
                          name: _nameController.text,
                          employeeNo: _employeeNumberController.text,
                          position: _positionController.text,
                          homeUnit: _homeUnitController.text,
                          email: _emailController.text,
                          username: "",
                          status: "cleared"
                        );

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
                            .signUp(_emailController.text, _passwordController.text);

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
                                  .addAccount(newEmployeeAccount, newUID!);
                              
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
                      "Next",
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

  dynamic _positionOnChanged() {
    void onChanged(String? value) {
      setState(() {
        _formValues['position'] = value;
      });
    }

    return onChanged;
  }

  dynamic _homeunitOnChanged() {
    void onChanged(String? value) {
      setState(() {
        _formValues['homeUnit'] = value;
      });
    }

    return onChanged;
  }
}

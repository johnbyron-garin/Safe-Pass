import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe_pass/screens/access/preexisting_illness.dart';

// import 'package:safe_pass/screens/preexisting_illness.dart';
import 'package:safe_pass/styles.dart';

import '../../models/account_model.dart';
import '../../providers/account_provider.dart';
import '../../providers/auth_provider.dart';
import 'not_a_student.dart';

class SignupStudent extends StatefulWidget {
  const SignupStudent({super.key});
  @override
  _SignupStudentState createState() => _SignupStudentState();
}

class _SignupStudentState extends State<SignupStudent> {
  final TextEditingController _nameController = TextEditingController();
  // final TextEditingController _collegeController = TextEditingController();
  // final TextEditingController _courseController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _studentNumberController =
      TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  static final _collegesAndCourses = {
    "College of Agriculture and Food Science": [
      "BS Agriculture",
      "BS Agricultural Biotechnology",
      "BS Food Science and Technology"
    ]..sort(),
    "College of Arts and Sciences": [
      "BA Communication Arts",
      "BA Philosophy",
      "BA Socioloogy",
      "BS Applied Mathematics",
      "BS Math and Science Teaching",
      "BS Applied Physics",
      "BS Biology",
      "BS Chemistry",
      "BS Computer Science",
      "BS Mathematics",
      "BS Statistics",
      "BS Agricultural Chemistry"
    ]..sort(),
    "College of Development Communication": ["BS Development Communication"],
    "College of Engineering and Agro-industrial Technology": [
      "BS Industrial Engineering",
      "BS Agricultural and Biosystems Engineering",
      "BS Chemical Engineering",
      "BS Civil Engineering",
      "BS Electrical Engineering",
      "BS Mechanical Engineering"
    ]..sort(),
    "College of Economics and Management": [
      "BS Agricultural and Applied Economics",
      "BS Agribusiness Management and Entrepreneuship",
      "BS Economics",
      "BS Accountancy",
      "Associate in Arts Entrepreneurship"
    ]..sort(),
    "College of Forestry and Natural Resources": [
      "Certificate in Forestry",
      "Associate of Science in Forestry",
      "BS Forestry"
    ]..sort(),
    "College of Human Ecology": [
      "Bachelor of Science in Human Ecology",
      "Bachelor of Science in Nutrition"
    ]..sort(),
    "College of Veterinary Medicine": ["Doctor of Veterinary Medicine"]
  };

  // ignore: prefer_final_fields
  var _formValues = {
    'college': null,
    'course': null,
    'studentNo': ""
  };

  var _hasSelectedCollege = false;

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
      children: [
        Text(
          "Sign Up",
          style: Styles.titleTextStyle_Pass,
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Wrap(
            children: [
              Text(
                'Not a student? ',
                style: TextStyle(fontWeight: FontWeight.w300),
              ),
              GestureDetector(
                // widget for clickable text
                child: Text(
                  'Click here.',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xff087F8C)),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const NotAStudent(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
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
              controller: _studentNumberController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter student number",
                  labelText: "Student number"),
              // Used onChanged insted of TextEditingController
              validator: (value) {
                // Value shouldnt be null or empty.
                if (value == null || value.isEmpty) {
                  return "Please enter your student number";
                }

                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: DropdownButtonFormField(
              isExpanded: true,
              value: _formValues['college'],
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Select your college"),
              onChanged: (String? value) {
                setState(() {
                  _formValues['college'] = value!;
                  _formValues['course'] = null;
                  _hasSelectedCollege = true;
                });
              },
              validator: (value) {
                if (value == null) {
                  return "Please select your college.";
                }

                return null;
              },
              items: _collegesAndCourses.keys
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
            ),
          ),
          DropdownButtonFormField(
            isExpanded: true,
            value: _formValues['course'],
            decoration: const InputDecoration(
                border: OutlineInputBorder(), hintText: "Select your course"),
            onChanged: _coursesOnChanged(),
            validator: (value) {
              if (value == null) {
                return "Please select your course,";
              }

              return null;
            },
            items: _collegesAndCourses[_formValues['college']]
                ?.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
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
              controller: _usernameController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter username",
                  labelText: "Username"),
              // Used onChanged insted of TextEditingController
              validator: (value) {
                // Value shouldnt be null or empty.
                if (value == null || value.isEmpty) {
                  return "Please enter your username";
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
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState?.save();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PreExistingIllness(
                              email: _emailController.text,
                              password: _passwordController.text,
                              account: _packageUserInfo(),
                            ),
                          ),
                        );
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

  dynamic _coursesOnChanged() {
    if (!_hasSelectedCollege) {
      return null;
    }

    void onChanged(String? value) {
      setState(() {
        _formValues['course'] = value;
      });
    }

    return onChanged;
  }

  Account _packageUserInfo() {
    return Account(
      userType: "student",
      name: _nameController.text,
      email: _emailController.text,
      username: _usernameController.text,
      college: _formValues['college'],
      course: _formValues['course'],
      studentNumber: _studentNumberController.text,
      status: "cleared"
    );
  }
}

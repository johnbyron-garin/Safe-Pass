import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe_pass/screens/user/home.dart';
import 'package:safe_pass/screens/access/signup_student.dart';
import '../../providers/account_provider.dart';
import '../../providers/auth_provider.dart';
import '../../styles.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Stream<User?> userStream = context.watch<AuthProvider>().uStream;

    return StreamBuilder(
        stream: userStream,
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
            ));
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (!snapshot.hasData) {
            return _loginScaffold(context);
          } else {
            context.read<AccountProvider>().fetchLoggedInAccount(context);

            Future.microtask(() {
              Navigator.pushReplacementNamed(context, '/home');
            });

            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        });
  }

  Widget _loginScaffold(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [_title(), _subTitle(), _loginForm()],
        ),
      ),
    );
  }

  Widget _title() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              "Safe",
              style: Styles.titleTextStyle_Safe,
            ),
            Text(
              "Pass",
              style: Styles.titleTextStyle_Pass,
            )
          ],
        ),
      ),
    );
  }

  Widget _subTitle() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Text(
          "A health monitoring app.",
          style: Styles.subtitleText,
        ),
      ),
    );
  }

  Widget _loginForm() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Email",
                    labelText: "Email"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your email.";
                  }

                  if (!RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                      .hasMatch(value)) {
                    return "Please enter a valid email.";
                  }

                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Password",
                    labelText: "Password"),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your password.";
                  }

                  if (value.length < 6) {
                    return 'Password must have atleast 6 characters';
                  }

                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: Styles.loginButtonStyle,
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState?.save();

                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Signing in"),
                                content: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    CircularProgressIndicator(),
                                  ],
                                ),
                              );
                            },
                          );

                          var uid = await context.read<AuthProvider>().signIn(
                                _emailController.text.trim(),
                                _passwordController.text.trim(),
                              );

                          // To-Do add login fails
                          /**
                           * Errors:
                           *  - user-not-found
                           *  - wrong-password
                           */
                          if (context.mounted) {
                            switch (uid) {
                              case "user-not-found":
                              case "wrong-password":
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text("Invalid email or password."),
                                ));
                                break;
                              default:
                                Navigator.of(context).pop();
                                context
                                    .read<AccountProvider>()
                                    .fetchLoggedInAccount(context);
                                // context.read<AuthProvider>().fetchUserObj();

                                Future.microtask(() {
                                  Navigator.pushReplacementNamed(
                                      context, '/home');
                                });
                            }
                          }
                        }
                      },
                      child: const Text(
                        "Log In",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                "No account yet?",
                style: TextStyle(fontWeight: FontWeight.w300),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SignupStudent(),
                  ),
                );
              },
              child: const Text("Sign Up",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}

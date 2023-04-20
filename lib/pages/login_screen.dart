import 'package:fbla_app_22/pages/licensing_page.dart';
import "package:flutter/material.dart";
import "package:bcrypt/bcrypt.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:fbla_app_22/global_vars.dart" as globals;
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseFirestore db = FirebaseFirestore.instance;

  var _errorMsg = "";

  // This function checks if the given email address is valid or not by using a regular expression pattern.
  // The email is trimmed before checking if it matches the pattern.
  // The pattern ensures that the email has certain characters before and after the '@' symbol,
  // and also checks for a valid domain name. The function returns true if the email is valid, otherwise false.
  bool isValidEmail(String email) {
    final pattern = RegExp(
        r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$');
    return pattern.hasMatch(email.trim());
  }

  @override
  // This is a function typically used in a Flutter application that builds the user interface of a
  // screen or widget. It takes in a BuildContext object as a parameter, allowing access to the
  // inherited properties of the widget tree. The specifics of what this function does will vary based
  // on the code inside of it.
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Login Screen'),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              child: Image.asset("assets/tstem.jpg"),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2.0,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(
                      color: Colors.blue.shade900,
                    ),
                  ),
                  labelStyle: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                  labelText: 'Email',
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2.0,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(
                      color: Colors.blue.shade900,
                    ),
                  ),
                  labelStyle: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                  labelText: 'Password',
                ),
                cursorColor: Theme.of(context).primaryColor,
              ),
            ),
            if (_errorMsg != "")
              Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Text(
                  _errorMsg,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            // It creates a widget that adds padding around its child widget.
            const Padding(
              padding: EdgeInsets.all(10),
            ),
            const Text(
              "If you don't have an account, clicking the button below will register you.",
              textAlign: TextAlign.center,
            ),
            Container(
              height: 80,
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  primary: Theme.of(context).primaryColor,
                ),
                child: const Text('Log In / Sign Up'),
                onPressed: () async {
                  // This function is called when the button is pressed.
                  // It checks if the email and password fields are empty, and if so, displays an error message.
                  // If the email is not valid, it displays an error message.
                  // If the password is not valid, it displays an error message.
                  // If the email and password are valid, it checks if the email is already in the database.
                  // If the email is not in the database, it adds the email and password to the database.
                  // If the email is in the database, it checks if the password matches the password in the database.
                  // If the password matches, it logs the user in.
                  // If the password does not match, it displays an error message.
                  if (!isValidEmail(_emailController.text)) {
                    setState(() {
                      _errorMsg = "Please enter a valid email";
                    });
                  } else if (_passwordController.text == "") {
                    setState(() {
                      _errorMsg = "Please enter a password";
                    });
                  } else if (_passwordController.text == "password") {
                    setState(() {
                      _errorMsg = "Make sure your password is not 'password'";
                    });
                  } else if (_passwordController.text.length < 8) {
                    setState(() {
                      _errorMsg =
                          "Make sure your password is at least 8 characters";
                    });
                  } else {
                    setState(() {
                      _errorMsg = "";
                    });

                    var res = await db
                        .collection("absences")
                        .doc(_emailController.text)
                        .get();

                    if (!res.exists) {
                      var hashedPassword = BCrypt.hashpw(
                          _passwordController.text, BCrypt.gensalt());

                      CollectionReference absences = db.collection("absences");

                      absences
                          .doc(_emailController.text)
                          .set({"password": hashedPassword});

                      if (!mounted) return;

                      globals.email = _emailController.text;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyHomePage(),
                        ),
                      );
                    } else {
                      var hashedPassword = res.data()!["password"];

                      if (BCrypt.checkpw(
                          _passwordController.text, hashedPassword)) {
                        if (!mounted) return;

                        globals.email = _emailController.text;
                        globals.emailType = res.data()!["accountType"];

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyHomePage(),
                          ),
                        );
                      } else {
                        setState(() {
                          _errorMsg = "Incorrect password";
                        });
                      }
                    }
                  }
                },
              ),
            ),
            TextButton(
              onPressed: () {
                String email = "info.schoolsync@gmail.com";
                String subject = "I found a bug!";
                String body =
                    "I found a bug in the app. Here's what happened: <add your description here>.";
                launchUrl(
                    Uri.parse("mailto:$email?subject=$subject&body=$body"));
              },
              style: TextButton.styleFrom(
                primary: Theme.of(context).primaryColor,
              ),
              child: Text(
                'Report a Bug',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LicensingPage(),
                  ),
                );
              },
              style: TextButton.styleFrom(
                primary: Theme.of(context).primaryColor,
              ),
              child: Text(
                'Terms of Use',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

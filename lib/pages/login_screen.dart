import "package:flutter/material.dart";
import "package:bcrypt/bcrypt.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:fbla_app_22/global_vars.dart" as globals;

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

  bool isValidEmail(String email) {
    final pattern = RegExp(
        r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$');
    return pattern.hasMatch(email.trim());
  }

  @override
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
                  if (_passwordController.text == "") {
                    setState(() {
                      _errorMsg = "Please enter a password";
                    });
                  } else if (!isValidEmail(_emailController.text)) {
                    setState(() {
                      _errorMsg = "Please enter a valid email";
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
              onPressed: () {},
              style: TextButton.styleFrom(
                primary: Theme.of(context).primaryColor,
              ),
              child: Text(
                'Forgot Password?',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

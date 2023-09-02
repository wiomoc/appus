import 'package:campus_flutter/base/networking/apis/campUSApi/campus_api.dart';
import 'package:campus_flutter/base/networking/apis/campUSApi/campus_api_exception.dart';
import 'package:campus_flutter/base/views/error_handling_view.dart';
import 'package:campus_flutter/providers_get_it.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../navigation.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<StatefulWidget> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool _processingLogin = false;
  bool _invalidCredentials = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(() {setState(() {});});
    _passwordController.addListener(() {setState(() {});});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor:
            MediaQuery.platformBrightnessOf(context) == Brightness.dark ? Theme.of(context).canvasColor : Colors.white,
        body: SafeArea(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const Image(
              image: AssetImage("assets/images/logos/tum-logo-blue.png"),
              height: 60,
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 10.0)),
            Text("Welcome to the TUM Campus App", style: Theme.of(context).textTheme.titleLarge),
            const Padding(padding: EdgeInsets.symmetric(vertical: 10.0)),
            Text("Enter your TUM ID to get started", style: Theme.of(context).textTheme.titleMedium),
            const Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
            _tumIdTextFields(context),
            const Padding(padding: EdgeInsets.symmetric(vertical: 10.0)),
            _loginButton(context),
            const Spacer(),
          ],
        )));
  }

  Widget _tumIdTextFields(BuildContext context) {
    return Column(
      children: [
        Padding(
            padding: EdgeInsets.all(4.0),
            child: TextField(
              decoration: const InputDecoration(hintText: "Username", border: OutlineInputBorder()),
              inputFormatters: [LengthLimitingTextInputFormatter(8)],
              controller: _usernameController,
              onChanged: (text) {
                if (text.length == 8) {
                  FocusScope.of(context).nextFocus();
                }
              },
              enableSuggestions: false,
            )),
        Padding(
            padding: EdgeInsets.all(4.0),
            child: TextField(
              decoration: const InputDecoration(hintText: "Password", border: OutlineInputBorder()),
              obscureText: true,
              controller: _passwordController,
              enableSuggestions: false,
            )),
      ],
    );
  }

  Widget _loginButton(BuildContext context) {
    return Column(
      children: [
        if (_invalidCredentials) const Text("Invalid Credentials", style: TextStyle(color: Colors.red)),
        ElevatedButton(
            onPressed:
                (!_processingLogin && _usernameController.text.isNotEmpty && _passwordController.text.isNotEmpty)
                    ? () {
                        setState(() {
                          _processingLogin = true;
                        });
                        getIt<CampusApi>().login(_usernameController.text, _passwordController.text).then((value) {
                          Navigator.of(context)
                              .pushReplacement(MaterialPageRoute(builder: (context) => const Navigation()));
                        }).onError((error, stacktrace) {
                          if (error is InvalidCampusCredentialsException) {
                            setState(() {
                              _processingLogin = false;
                              _invalidCredentials = true;
                            });
                          } else {
                            setState(() {
                              _processingLogin = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                duration: const Duration(seconds: 10),
                                content: ErrorHandlingView(
                                  error: error!,
                                  errorHandlingViewType: ErrorHandlingViewType.textOnly,
                                  titleColor: Colors.white,
                                )));
                          }
                        });
                      }
                    : null,
            child: Text("Log in", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white))),
      ],
    );
  }

  Widget _towerImage() {
    return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 64.0),
        child: Image(image: AssetImage("assets/images/tower.png"), fit: BoxFit.contain));
  }

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
  }
}

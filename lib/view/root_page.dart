import 'dart:ui';

import 'package:firebase_todo/services/authentication.dart';
import 'package:firebase_todo/services/signin_signup_page.dart';
import 'package:firebase_todo/view/home_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

enum Authstatus { NOT_DETERMINE, NOT_SIGN_IN, SIGN_IN }

class RootPage extends StatefulWidget {
  final BaseAuth auth;

  const RootPage({Key key, this.auth}) : super(key: key);

  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  Authstatus authstatus = Authstatus.NOT_DETERMINE;
  String userId = "";
  @override
  void initState() {
    super.initState();

    widget.auth.getCurrentUser().then((user) {
      setState(() {
        if (user != null) {
          userId = user.uid;
        }
        authstatus =
            (user?.uid == null ? Authstatus.NOT_SIGN_IN : Authstatus.SIGN_IN);
      });
    }); //then is keyword in future class (abstract)
  }

  void signInCallback() {
    widget.auth.getCurrentUser().then((value) {
      setState(() {
        userId = value.uid.toString();
        authstatus = Authstatus.SIGN_IN;
      });
    });
  }

  void signOutcallback() {
    setState(() {
      authstatus = Authstatus.NOT_SIGN_IN;
    });
  }

  Widget waitingScreen() {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (authstatus) {
      case Authstatus.NOT_DETERMINE:
        return waitingScreen();
        break;

      case Authstatus.NOT_SIGN_IN:
        return SignInSignUpPage(
          auth: widget.auth,
          signInCallback: signInCallback,
        );
        break;
      case Authstatus.SIGN_IN:
        if (userId.length > 0 && userId != null) {
          return HomePage(
              auth: widget.auth,
              signOutCallback: signOutcallback,
              userId: userId);
        } else {
          return waitingScreen();
        }
        break;

      default:
        return waitingScreen();
    }
  }
}

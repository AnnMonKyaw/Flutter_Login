import 'package:firebase_todo/services/authentication.dart';
import 'package:flutter/material.dart';

class SignInSignUpPage extends StatefulWidget {
  final BaseAuth auth;
  final VoidCallback signInCallback;

  const SignInSignUpPage({Key key, this.auth, this.signInCallback})
      : super(key: key);

  //SignInSignUpPage({Key key,this.auth,this.signInCallback});
  @override
  _SignInSignUpPageState createState() => _SignInSignUpPageState();
}

class _SignInSignUpPageState extends State<SignInSignUpPage> {
  final formKey = GlobalKey<FormState>();
  bool _isLoading;
  String _email, _password, _errorMessage;
  bool _isSignInForm;

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Widget showForm() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Form(
          key: formKey,
          child: ListView(
            children: [
              showEmailInput(),
              showPasswordInput(),
              showPrimaryButton(),
              showSecondaryButton()
            ],
          )),
    );
  }

  void validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    if (validateAndSave()) {
      String userId = "";
      try {
        if (_isSignInForm) {
          userId = await widget.auth.signIn(_email, _password);

          print("user id" + userId);
        } else {
          userId = await widget.auth.signUp(_email, _password);
        }
        setState(() {
          _isLoading = false;
        });
        if (userId.length > 0 && userId != null && _isSignInForm == true) {
          widget.signInCallback();
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.message;
          formKey.currentState.reset();
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _errorMessage = "";
    _isLoading = false;
    _isSignInForm = true;
  }

  void resetForm() {
    formKey.currentState.reset();
    _errorMessage = "";
  }

  void toggleForm() {
    resetForm();
    setState(() {
      _isSignInForm = !_isSignInForm;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: Text("Flutter ToDo"),
      ),
      body: Stack(
        children: [showCircularrogress(), showForm()],
      ),
    );
  }

  Widget showCircularrogress() {
    print(_isLoading);
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Container(
      width: 0,
      height: 0,
    );
  }

  Widget showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return Text(
        _errorMessage,
        style: TextStyle(color: Colors.red, fontSize: 12),
      );
    } else {
      return Container(
        height: 0,
      );
    }
  }

  Widget showEmailInput() {
    return Padding(
      padding: EdgeInsets.only(top: 100),
      child: TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: InputDecoration(
            hintText: "Email",
            icon: Icon(
              Icons.mail,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? "Email can\'t be empty" : null,
        onSaved: (value) => _email = value.trim(),
      ),
    );
  }

  Widget showPasswordInput() {
    return Padding(
      padding: EdgeInsets.only(top: 100),
      child: TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: InputDecoration(
            hintText: "Password",
            icon: Icon(
              Icons.lock,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? "Password can\'t be empty" : null,
        onSaved: (value) => _password = value.trim(),
      ),
    );
  }

  Widget showPrimaryButton() {
    return Padding(
      padding: EdgeInsets.only(top: 30),
      child: RaisedButton(
        onPressed: validateAndSubmit,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        color: Colors.blue,
        child: Text(
          _isSignInForm ? 'Sign In' : 'Create Account',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget showSecondaryButton() {
    return Padding(
      padding: EdgeInsets.only(top: 30),
      child: FlatButton(
        onPressed: toggleForm,
        child: Text(
          _isSignInForm ? 'Create Account' : 'Already created? Sign In',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

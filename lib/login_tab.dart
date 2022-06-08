import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class LoginTab extends StatefulWidget {
  static const title = "Login";
  static const icon = Icon(Icons.key);

  const LoginTab({super.key});

  @override
  State<LoginTab> createState() => _LoginTabState();
}

class _LoginTabState extends State<LoginTab> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
    
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(LoginTab.title),
      ),
      body: constructForm(context),
    );
  }

  Widget constructForm(BuildContext context) {
    return Column(
      children: <Widget> [
        FormBuilder(
          key: _formKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: Column(
            children: <Widget> [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: FormBuilderTextField(
                  name: "email",
                  decoration: const InputDecoration(
                    labelText: "E-mail",
                    hintText: "example@gmail.com",
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.email()
                  ]),
                  keyboardType: TextInputType.text,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: FormBuilderTextField(
                  name: "password",
                  decoration: const InputDecoration(
                    labelText: "Password",
                  ),
                  validator: FormBuilderValidators.required(),
                  keyboardType: TextInputType.text,
                  obscureText: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: MaterialButton(
                  color: Theme.of(context).colorScheme.secondary,
                  child: const Text(
                    "Login",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () { onLoginPressed(); },
                ),
              )
            ]
          )
        ),
      ]
    );
  }

  void onLoginPressed() async {
    if (_formKey.currentState == null) {
      return;
    }

    if (!_formKey.currentState!.saveAndValidate()) {
      return;
    }
    var costam = _formKey.currentState!.fields["email"].toString();
    FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _formKey.currentState!.fields["email"]!.value.toString(),
      password: _formKey.currentState!.fields["password"]!.value.toString(),
    ).then(
      (response) => Navigator.pop(context),
      onError: (error) {
        showSnackbar("Something went wrong, please try once again.");
      }
    );
  }

  void showSnackbar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }
}
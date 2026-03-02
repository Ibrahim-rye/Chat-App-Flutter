import 'package:chatapp/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/components/my_button.dart';
import 'package:chatapp/components/my_textfield.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _confirmPwController = TextEditingController();

  Future<void> register() async {
    final auth = AuthService();

    if (_pwController.text != _confirmPwController.text) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text("Passwords do not match!"),
        ),
      );
      return;
    }

    try {
      // 1. Create user in Firebase Auth
      final userCredential = await auth.createUserWithEmailAndPassword(
        _emailController.text.trim(),
        _pwController.text.trim(),
      );

      // 3. Save additional user info to Firestore
      await auth.saveAdditionalUserInfo(
        userId: userCredential.user!.uid,
        email: _emailController.text.trim(),
        username: _usernameController.text.trim(),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Registration Error"),
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Icon(
              Icons.message,
              size: 60,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 40),
            Text(
              "Let's create an account for you!",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            MyTextField(hintText: "Username", controller: _usernameController),
            const SizedBox(height: 10),
            MyTextField(hintText: "Email", controller: _emailController),
            const SizedBox(height: 10),
            MyTextField(hintText: "Password", controller: _pwController),
            const SizedBox(height: 10),
            MyTextField(
                hintText: "Confirm Password", controller: _confirmPwController),
            const SizedBox(height: 20),
            MyButton(text: "Register", onTap: register),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account? "),
                GestureDetector(
                  onTap: widget.onTap,
                  child: const Text("Login now",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

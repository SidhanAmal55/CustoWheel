import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:CustoWheel/screens/home_screen.dart'; // Your customer home screen
import 'package:firebase_auth/firebase_auth.dart';

class LoginDemo1 extends StatefulWidget {
  const LoginDemo1({super.key});

  @override
  State<LoginDemo1> createState() => _LoginDemo1State();
}

class _LoginDemo1State extends State<LoginDemo1> {
  @override
  Widget build(BuildContext context) {
    return LoginScreen();
  }
}

class LoginScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

   LoginScreen({super.key});
  Duration get loginTime => Duration(milliseconds: 2250);

 Future<String?> _authUser(LoginData data) async {
  try {
    if (!data.name.contains('@')) return 'Invalid email format';

    // Try to sign in
    await _auth.signInWithEmailAndPassword(
      email: data.name,
      password: data.password,
    );
    return null; // success
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      return 'User not exists';
    } else if (e.code == 'wrong-password') {
      return 'Password is incorrect';
    } else {
      return 'Login failed. Invalid email or password ';
    }
  }
}



  Future<String?> _signupUser(SignupData data) async {
    try {
      if (data.name == null || data.password == null) {
        return 'Email and password cannot be empty';
      }
      if (!data.name!.contains('@')) return 'Invalid email format';
      await _auth.createUserWithEmailAndPassword(
        email: data.name!,
        password: data.password!,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  
Future<String> _recoverPassword(String name) async {
  try {
    await _auth.sendPasswordResetEmail(email: name);
    return "A password reset email has been sent to $name.";
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      return 'No user found with this email';
    }
    return 'Something went wrong. Try again later.';
  }
}


  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: ' Login to CustoWheel',
      logo: AssetImage('assets/images/logo.png'),
      theme: LoginTheme(
        pageColorDark: const Color(0xFF1C1B33),
    titleStyle: TextStyle(
      color: const Color.fromARGB(255, 237, 234, 244),  // Change this to any color
      fontSize: 28,              // Customize font size
      fontWeight: FontWeight.bold,
    ),

    // ✅ Style the logo size
    logoWidth: 150, // Change this to increase or decrease logo size
  ),
      onLogin: _authUser,
      onSignup: _signupUser,
      onSubmitAnimationCompleted: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      },
      onRecoverPassword: _recoverPassword,
    );
  }
}

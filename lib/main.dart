import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:CustoWheel/firebase_options.dart';
//import 'package:myapp/screens/home_screen.dart';
import 'package:CustoWheel/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Customer Lookup',
      debugShowCheckedModeBanner: false,
      home: ImageSplash(),
    );
  }
}
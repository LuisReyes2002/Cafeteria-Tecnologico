import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lince_time/src/routes/routes.dart';
import 'package:lince_time/src/login_and_register_provider/login_provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUserSession();
    });
  }

  Future<void> _checkUserSession() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final lastScreen = await LoginProvider().getLastScreen();

      if (lastScreen != null && lastScreen.isNotEmpty) {
        Navigator.pushReplacementNamed(context, lastScreen);
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists && userDoc.data()!.containsKey('role')) {
        final String role = userDoc.get('role');

        if (role == 'admin') {
          await LoginProvider().saveLastScreen('/admin');
          Navigator.pushReplacementNamed(context, '/admin');
        } else if (role == 'user') {
          await LoginProvider().saveLastScreen('/home');
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        await FirebaseAuth.instance.signOut();
        Navigator.pushReplacementNamed(context, Routes.login);
      }
    } else {
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.pushReplacementNamed(context, Routes.login);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/splash.png', width: 400, height: 400),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../utils/gen/assets.gen.dart';

class SplashViewBody extends StatefulWidget {
  const SplashViewBody({super.key});

  @override
  State<SplashViewBody> createState() => _SplashViewBodyState();
}

class _SplashViewBodyState extends State<SplashViewBody> {
  @override
  void initState() {
    super.initState();
    navigateToNextScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Assets.images.logo
            .svg(width: 150.w)
            .animate()
            .slideX(duration: Duration(seconds: 1), begin: -1, end: 0)
            .fadeIn(duration: Duration(milliseconds: 1500)),
      ],
    );
  }

  void navigateToNextScreen() async {
    // إضافة تأخير بسيط قبل التوجيه
    await Future.delayed(Duration(seconds: 3));

    // التحقق من حالة تسجيل الدخول باستخدام FirebaseAuth
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // إذا كان المستخدم قد سجل الدخول، التوجيه إلى الصفحة الرئيسية
      Navigator.pushReplacementNamed(
        context,
        '/home',
      ); // قم بتغيير '/home' إلى المسار الخاص بالصفحة الرئيسية
    } else {
      // إذا لم يكن قد سجل الدخول، التوجيه إلى صفحة تسجيل الدخول
      Navigator.pushReplacementNamed(
        context,
        '/login',
      ); // قم بتغيير '/login' إلى المسار الخاص بتسجيل الدخول
    }
  }
}

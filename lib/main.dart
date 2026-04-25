import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'core/theme.dart';
import 'logic/call_cubit/call_cubit.dart';
import 'ui/screens/home_screen.dart';
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Request permissions
  await [
    Permission.camera,
    Permission.microphone,
  ].request();

  runApp(const VocalisApp());
}

class VocalisApp extends StatelessWidget {
  const VocalisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
//Random user ID for demo purposes; replace with actual auth logic in production
//     في المستقبل (Production):
//     لما التطبيق يكون جاهز وفيه نظام تسجيل دخول (Login)، الـ ID ده هيجي من:
//
//     Firebase Auth: اللي هو الـ User.uid.
//     أو قاعدة البيانات بتاعتك: الرقم التعريفي للمستخدم.
//     نصيحة للتجربة: عشان ما تقعدش تغير الكود كل شوية، ممكن تخلي الـ ID رقم عشوائي مؤقتاً:
//

      create: (context) =>
          CallCubit()..connect('user_${Random().nextInt(100)}'),
      child: MaterialApp(
        title: 'Vocalis WebRTC',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const HomeScreen(),
      ),
    );
  }
}

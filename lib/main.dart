import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'core/theme.dart';
import 'logic/call_cubit/call_cubit.dart';
import 'ui/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
      create: (context) => CallCubit()..connect('my_user_id'), // Mock user ID
      child: MaterialApp(
        title: 'Vocalis WebRTC',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const HomeScreen(),
      ),
    );
  }
}

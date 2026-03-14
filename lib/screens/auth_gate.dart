import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/bottom_nav.dart';
import 'login_page.dart';

final supabase = Supabase.instance.client;

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final session = supabase.auth.currentSession;

    if (session != null) {
      return const BottomNav(); // your main app
    } else {
      return const LoginPage(); // login screen
    }
  }
}
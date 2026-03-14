import 'package:flutter/material.dart';
import 'widgets/bottom_nav.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://piaxgaebpjcrxscgkuuz.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBpYXhnYWVicGpjcnhzY2drdXV6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM0NzA2NTEsImV4cCI6MjA4OTA0NjY1MX0.obgQ9iyEXH7ENJqJTESgflvITW6Y8IlWd8QaPC-gKQw',
  );

  runApp(const CrowdPredictApp());
}

class CrowdPredictApp extends StatelessWidget {
  const CrowdPredictApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crowd Predictor',
      debugShowCheckedModeBanner: false,
      home: const BottomNav(),
    );
  }
}

import 'package:flutter/material.dart';
import 'widgets/bottom_nav.dart';

void main() {
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

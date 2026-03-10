import 'package:flutter/material.dart';
import '../widgets/floating_mic.dart';
import 'predict_screen.dart';
import 'event_calendar_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Travelytics"),
        backgroundColor: Colors.deepPurple, // Optional: make it colorful
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 50),
                  ),
                  child: const Text("Predict Crowd Level"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PredictScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 50),
                  ),
                  child: const Text("Event Calendar"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EventCalendarScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const FloatingMic(), // Your floating mic widget
        ],
      ),
    );
  }
}

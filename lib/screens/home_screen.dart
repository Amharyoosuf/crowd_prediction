import 'package:flutter/material.dart';
import '../widgets/floating_mic.dart';
import 'event_calendar_screen.dart';
import 'predict_crowd_level.dart';
import 'budget_prediction_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Travelstatics"),
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
                  child: const Text("View Prediction Result"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PredictCrowdLevelScreen(),
                      ),
                    );
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 50),
                  ),
                  child: const Text("Predict Trip Budget"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BudgetPredictionScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
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

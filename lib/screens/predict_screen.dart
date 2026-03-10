import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Import your alternative location screen
import 'Alternative_location_screen.dart'; // Adjust path if needed

class PredictScreen extends StatefulWidget {
  const PredictScreen({super.key});

  @override
  State<PredictScreen> createState() => _PredictScreenState();
}

class _PredictScreenState extends State<PredictScreen> {
  final TextEditingController monthController = TextEditingController();
  final TextEditingController placeController = TextEditingController();
  String result = "";
  String crowdLevel = ""; // Store the crowd level from backend
  bool loading = false;

  Future<void> predictCrowd() async {
    final month = monthController.text.trim();
    final place = placeController.text.trim();

    if (month.isEmpty || place.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Enter both fields")));
      return;
    }

    setState(() {
      loading = true;
      result = "";
      crowdLevel = "";
    });

    try {
      final url = Uri.parse("https://crowd-backend-0c2r.onrender.com/predict");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"month": month, "place": place}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          crowdLevel = data['crowd_level'];
          result = "Predicted Crowd Level: ${crowdLevel}";
        });
      } else {
        setState(() {
          result = "Error: ${response.statusCode} - ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        result = "Failed to connect to the server. Error: $e";
      });
    }

    setState(() {
      loading = false;
    });
  }

  @override
  void dispose() {
    monthController.dispose();
    placeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Predict Crowd Level")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: monthController,
              decoration: const InputDecoration(
                labelText: "Month",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: placeController,
              decoration: const InputDecoration(
                labelText: "Place",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : predictCrowd,
              child: loading
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Text("Predict"),
            ),
            const SizedBox(height: 20),
            Text(
              result,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Show "Get Alternative Locations" button only if crowd level is High
            if (crowdLevel.toLowerCase() == "high")
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AlternativeLocationScreen(),
                    ),
                  );
                },
                child: const Text("Get Alternative Locations"),
                //elvated scenegit status

              ),
          ],
        ),
      ),
    );
  }
}
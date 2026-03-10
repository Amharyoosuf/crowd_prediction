import 'package:flutter/material.dart';
import '../models/prediction_response.dart';
import '../services/api_service.dart';

class PredictCrowdLevelScreen extends StatefulWidget {
  const PredictCrowdLevelScreen({super.key});

  @override
  State<PredictCrowdLevelScreen> createState() =>
      _PredictCrowdLevelScreenState();
}

class _PredictCrowdLevelScreenState extends State<PredictCrowdLevelScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController monthController = TextEditingController();
  final TextEditingController placeController = TextEditingController();
  final TextEditingController temperatureController = TextEditingController();
  final TextEditingController eventsController = TextEditingController();

  bool isLoading = false;
  PredictionResponse? result;
  String? errorMessage;

  Future<void> submitPrediction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
      result = null;
    });

    try {
      final response = await ApiService.predictCrowd(
        month: monthController.text.trim(),
        place: placeController.text.trim(),
        temperature: double.parse(temperatureController.text.trim()),
        events: double.parse(eventsController.text.trim()),
      );

      setState(() {
        result = response;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Color crowdColor(String crowd) {
    switch (crowd.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    monthController.dispose();
    placeController.dispose();
    temperatureController.dispose();
    eventsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tourism Crowd Predictor'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: monthController,
                decoration: const InputDecoration(
                  labelText: 'Month',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.trim().isEmpty ? 'Enter month' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: placeController,
                decoration: const InputDecoration(
                  labelText: 'Place',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.trim().isEmpty ? 'Enter place' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: temperatureController,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Temperature',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter temperature';
                  }
                  if (double.tryParse(value.trim()) == null) {
                    return 'Enter valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: eventsController,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Events',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter events';
                  }
                  if (double.tryParse(value.trim()) == null) {
                    return 'Enter valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : submitPrediction,
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Predict Crowd'),
                ),
              ),
              const SizedBox(height: 20),
              if (errorMessage != null)
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              if (result != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result!.place,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Month: ${result!.month}'),
                        Text('Category: ${result!.category ?? "Unknown"}'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text(
                              'Predicted Crowd: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: crowdColor(result!.predictedCrowd),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                result!.predictedCrowd.toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (result!.alternatives.isNotEmpty) ...[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Alternative Places',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...result!.alternatives.map(
                        (alt) => Card(
                      child: ListTile(
                        title: Text(alt.place),
                        subtitle: Text(
                          'Category: ${alt.category}\n'
                              'Month: ${alt.month}\n'
                              'Temperature: ${alt.temperature}',
                        ),
                        trailing: Text(
                          alt.predictedCrowd.toUpperCase(),
                          style: TextStyle(
                            color: crowdColor(alt.predictedCrowd),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ] else if (result!.predictedCrowd.toLowerCase() != 'high') ...[
                  const Text('No alternatives needed for this place.')
                ] else ...[
                  const Text('No same-category alternatives available.')
                ]
              ]
            ],
          ),
        ),
      ),
    );
  }
}
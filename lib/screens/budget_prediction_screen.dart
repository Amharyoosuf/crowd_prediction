import 'package:flutter/material.dart';
import '../services/budget_api_service.dart';

class BudgetPredictionScreen extends StatefulWidget {
  const BudgetPredictionScreen({super.key});

  @override
  State<BudgetPredictionScreen> createState() => _BudgetPredictionScreenState();
}

class _BudgetPredictionScreenState extends State<BudgetPredictionScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController adultsController = TextEditingController();
  final TextEditingController childrensController = TextEditingController();
  final TextEditingController daysController = TextEditingController();

  String selectedClass = 'Normal';
  final List<String> classes = ['Budget', 'Normal', 'High Class'];

  final List<String> allDistricts = ['Colombo', 'Kandy', 'Galle'];
  final List<String> selectedDistricts = [];

  bool isLoading = false;
  Map<String, dynamic>? result;
  String? errorMessage;

  Future<void> submitBudgetPrediction() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedDistricts.isEmpty) {
      setState(() {
        errorMessage = 'Please select at least one district';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      result = null;
    });

    try {
      final response = await BudgetApiService.predictBudget(
        adults: int.parse(adultsController.text.trim()),
        childrens: int.parse(childrensController.text.trim()),
        days: int.parse(daysController.text.trim()),
        travelClass: selectedClass,
        districts: selectedDistricts,
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

  @override
  void dispose() {
    adultsController.dispose();
    childrensController.dispose();
    daysController.dispose();
    super.dispose();
  }

  Widget buildDistrictSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Districts',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        ...allDistricts.map(
              (district) => CheckboxListTile(
            title: Text(district),
            value: selectedDistricts.contains(district),
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  selectedDistricts.add(district);
                } else {
                  selectedDistricts.remove(district);
                }
              });
            },
          ),
        ),
      ],
    );
  }

  Widget buildResultCard() {
    if (result == null) return const SizedBox();

    return Card(
      margin: const EdgeInsets.only(top: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Budget Prediction Result',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Estimated Cost: ${result!['estimated_cost_lkr']} LKR',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Prediction'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: adultsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Adults',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter number of adults';
                  }
                  if (int.tryParse(value.trim()) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: childrensController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Children',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter number of children';
                  }
                  if (int.tryParse(value.trim()) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: daysController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Days',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter number of days';
                  }
                  if (int.tryParse(value.trim()) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedClass,
                decoration: const InputDecoration(
                  labelText: 'Class',
                  border: OutlineInputBorder(),
                ),
                items: classes.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedClass = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              buildDistrictSelector(),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : submitBudgetPrediction,
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Predict Budget'),
                ),
              ),
              const SizedBox(height: 16),
              if (errorMessage != null)
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              buildResultCard(),
            ],
          ),
        ),
      ),
    );
  }
}
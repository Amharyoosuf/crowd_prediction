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

  final List<String> allDistricts = [
    'Kandy',
    'Galle',
    'Trincomalee',
    'Colombo',
    'Matara',
    'Hambantota',
    'Nuwara Eliya',
    'Ella',
    'Anuradhapura',
    'Polonnaruwa',
  ];

  final List<String> selectedDistricts = [];

  bool isLoading = false;
  Map<String, dynamic>? result;
  String? errorMessage;

  Future<void> submitBudgetPrediction() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedDistricts.isEmpty) {
      setState(() {
        errorMessage = 'Please select at least one destination';
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

  Widget buildTopHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Text(
            'Budget Prediction',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Plan your trip and get an estimated travel cost instantly.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDistrictSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_on, color: Color(0xFF1565C0)),
              SizedBox(width: 8),
              Text(
                'Select Destinations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose one or more places for your trip.',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: allDistricts.map((district) {
              final isSelected = selectedDistricts.contains(district);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      selectedDistricts.remove(district);
                    } else {
                      selectedDistricts.add(district);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                      colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
                    )
                        : null,
                    color: isSelected ? null : const Color(0xFFF5F7FB),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : Colors.grey.shade300,
                    ),
                    boxShadow: isSelected
                        ? [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected
                            ? Icons.check_circle
                            : Icons.place_outlined,
                        size: 18,
                        color: isSelected ? Colors.white : Colors.black54,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        district,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget buildInputCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          buildTextField(
            controller: adultsController,
            label: 'Adults',
            icon: Icons.person,
            validatorMessage: 'Enter number of adults',
          ),
          const SizedBox(height: 14),
          buildTextField(
            controller: childrensController,
            label: 'Children',
            icon: Icons.child_care,
            validatorMessage: 'Enter number of children',
          ),
          const SizedBox(height: 14),
          buildTextField(
            controller: daysController,
            label: 'Days',
            icon: Icons.calendar_today,
            validatorMessage: 'Enter number of days',
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: selectedClass,
            decoration: InputDecoration(
              labelText: 'Travel Class',
              prefixIcon: const Icon(Icons.workspace_premium),
              filled: true,
              fillColor: const Color(0xFFF7F9FC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF1E88E5),
                  width: 1.4,
                ),
              ),
            ),
            items: classes.map((item) {
              return DropdownMenuItem<String>(
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
        ],
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String validatorMessage,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFF7F9FC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF1E88E5),
            width: 1.4,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return validatorMessage;
        }
        if (int.tryParse(value.trim()) == null) {
          return 'Enter a valid number';
        }
        return null;
      },
    );
  }

  Widget buildPredictButton() {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF7043), Color(0xFFFFC107)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : submitBudgetPrediction,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.5,
          ),
        )
            : const Text(
          'Predict Budget',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget buildResultCard() {
    if (result == null) return const SizedBox();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_balance_wallet, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Budget Prediction Result',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                const Text(
                  'Estimated Cost',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${result!['estimated_cost_lkr']} LKR',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FC),
      body: SafeArea(
        child: Column(
          children: [
            buildTopHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      buildDistrictSelector(),
                      const SizedBox(height: 16),
                      buildInputCard(),
                      const SizedBox(height: 20),
                      buildPredictButton(),
                      const SizedBox(height: 16),
                      if (errorMessage != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      buildResultCard(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
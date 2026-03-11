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

  final List<Map<String, String>> allDistricts = [
    {'name': 'Kandy', 'image': 'assets/images/kandy.jpeg'},
    {'name': 'Galle', 'image': 'assets/images/galle.jpeg'},
    {'name': 'Trincomalee', 'image': 'assets/images/trincomalee.jpg'},
    {'name': 'Colombo', 'image': 'assets/images/colombo.jpeg'},
    {'name': 'Matara', 'image': 'assets/images/matara.jpeg'},
    {'name': 'Hambantota', 'image': 'assets/images/hambanthota.jpeg'},
    {'name': 'Nuwara Eliya', 'image': 'assets/images/Nuwara eliya.jpeg'},
    {'name': 'Ella', 'image': 'assets/images/ella.jpeg'},
    {'name': 'Anuradhapura', 'image': 'assets/images/Anuradhapura.jpeg'},
    {'name': 'Polonnaruwa', 'image': 'assets/images/polannaruwa.jpeg'},
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
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: allDistricts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.25,
            ),
            itemBuilder: (context, index) {
              final district = allDistricts[index];
              final districtName = district['name']!;
              final imagePath = district['image']!;
              final isSelected = selectedDistricts.contains(districtName);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      selectedDistricts.remove(districtName);
                    } else {
                      selectedDistricts.add(districtName);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF1565C0)
                          : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.15),
                                Colors.black.withOpacity(0.55),
                              ],
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Positioned(
                            top: 8,
                            right: 8,
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.check,
                                size: 18,
                                color: Color(0xFF1565C0),
                              ),
                            ),
                          ),
                        Positioned(
                          left: 12,
                          right: 12,
                          bottom: 12,
                          child: Text(
                            districtName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
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

        final number = int.tryParse(value.trim());

        if (number == null) {
          return 'Enter a valid number';
        }

        if (number <= 0) {
          return 'Value must be greater than 0';
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
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.35),
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
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Estimated Cost',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${result!['estimated_cost_lkr']} LKR',
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
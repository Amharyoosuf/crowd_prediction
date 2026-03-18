import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/prediction_response.dart';
import '../services/api_service.dart';

class PlaceLocation {
  final double lat;
  final double lng;

  const PlaceLocation({
    required this.lat,
    required this.lng,
  });
}

class PredictCrowdLevelScreen extends StatefulWidget {
  const PredictCrowdLevelScreen({super.key});

  @override
  State<PredictCrowdLevelScreen> createState() =>
      _PredictCrowdLevelScreenState();
}

class _PredictCrowdLevelScreenState extends State<PredictCrowdLevelScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController placeController = TextEditingController();
  final TextEditingController temperatureController = TextEditingController();
  final TextEditingController eventsController = TextEditingController();

  String? selectedMonth;

  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  final List<String> places = [
    'Yala',
    'Horton Plains',
    'Udawalawa',
    'Minneriya',
    'Hurulu Eco Park',
    'Kanneliya',
    'Sinharaja Forest',
    'Knuckles',
    'Mirissa',
    'Pigeon Island',
    'Wilpattu',
    'Peradeniya',
    'Pinnawala',
    'Galle Museum',
    'Sigiriya',
    'Eth Athurusewana',
    'Kaudulla',
    'Jaffna Fort',
    'Jethawanaya',
    'Colombo National Museum',
    'Dehiwala Zoo',
    'Diyaluma Falls',
    'Bambarakanda Falls',
    'Belihuloya',
    'Victoria Park Nuwara Eliya',
    'Riverston',
    'Hanthana',
    'Kitulgala',
    'Ella Rock',
    'Adams Peak',
    'Meemure',
    'Kalpitiya Adventure',
    'Arugam Bay Surf',
    'Madulsima',
    'Ritigala Trek',
    'Hikkaduwa Diving',
    'Nilaveli Diving',
    'Lahugala',
    'Gal Oya',
    'Kandy Temple',
    'Anuradhapura',
    'Polonnaruwa',
    'Dambulla',
    'Kataragama',
    'Ruwanwelisaya',
    'Mihintale',
    'Unawatuna',
    'Bentota',
    'Pasikuda',
    'Nilaveli Beach',
    'Trincomalee',
    'Hiriketiya',
    'Kalutara',
    'Tangalle',
    'Kalpitiya Beach',
  ];



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
        month: selectedMonth!.trim(),
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

  Future<void> openGoogleMaps(String placeName) async {
    final encodedPlace = Uri.encodeComponent(placeName);

    final Uri googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$encodedPlace',
    );

    try {
      final launched = await launchUrl(
        googleMapsUrl,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Google Maps')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening map: $e')),
      );
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

  String capitalizeWords(String text) {
    if (text.trim().isEmpty) return text;
    return text
        .split(' ')
        .map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    })
        .join(' ');
  }

  @override
  void dispose() {
    placeController.dispose();
    temperatureController.dispose();
    eventsController.dispose();
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
            'Crowd Prediction',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Predictions are made by ML models. Please do not rely on it 100%.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
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
          DropdownButtonFormField<String>(
            value: selectedMonth,
            decoration: InputDecoration(
              labelText: 'Month',
              prefixIcon: const Icon(Icons.calendar_month),
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
            items: months.map((month) {
              return DropdownMenuItem<String>(
                value: month,
                child: Text(month),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedMonth = value;
              });
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Select month';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          buildPlaceAutocompleteField(),
          const SizedBox(height: 14),
          buildTextField(
            controller: temperatureController,
            label: 'Temperature',
            icon: Icons.thermostat,
            validatorMessage: 'Enter temperature',
          ),
          const SizedBox(height: 14),
          buildTextField(
            controller: eventsController,
            label: 'Events',
            icon: Icons.event,
            validatorMessage: 'Enter events',
          ),
        ],
      ),
    );
  }

  Widget buildPlaceAutocompleteField() {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return places;
        }
        return places.where(
              (place) =>
              place.toLowerCase().contains(textEditingValue.text.toLowerCase()),
        );
      },
      onSelected: (String selection) {
        placeController.text = selection;
      },
      fieldViewBuilder: (
          BuildContext context,
          TextEditingController textEditingController,
          FocusNode focusNode,
          VoidCallback onFieldSubmitted,
          ) {
        textEditingController.text = placeController.text;

        textEditingController.selection = TextSelection.fromPosition(
          TextPosition(offset: textEditingController.text.length),
        );

        textEditingController.addListener(() {
          placeController.text = textEditingController.text;
        });

        return TextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'Place',
            prefixIcon: const Icon(Icons.place),
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
              return 'Enter place';
            }
            if (!places
                .map((e) => e.toLowerCase())
                .contains(value.trim().toLowerCase())) {
              return 'Select a place from the list';
            }
            return null;
          },
        );
      },
      optionsViewBuilder: (
          BuildContext context,
          AutocompleteOnSelected<String> onSelected,
          Iterable<String> options,
          ) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: MediaQuery.of(context).size.width - 32,
              constraints: const BoxConstraints(maxHeight: 250),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    leading: const Icon(Icons.place_outlined),
                    title: Text(option),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
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
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
        if (double.tryParse(value.trim()) == null) {
          return 'Enter valid number';
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
          colors: [Color(0xFF1565C0), Color(0xFF26A69A)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : submitPrediction,
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
          'Predict Crowd',
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
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF26A69A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withOpacity(0.28),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.analytics_rounded, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                'Prediction Result',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  capitalizeWords(result!.place),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _resultInfoTile(
                        icon: Icons.calendar_month_rounded,
                        title: 'Month',
                        value: result!.month,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _resultInfoTile(
                        icon: Icons.category_rounded,
                        title: 'Category',
                        value: result!.category ?? 'Unknown',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Predicted Crowd Level',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: crowdColor(result!.predictedCrowd),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    result!.predictedCrowd.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAlternativesSection() {
    if (result == null) return const SizedBox();

    if (result!.alternatives.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFF1FAF6),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              result!.predictedCrowd.toLowerCase() != 'high'
                  ? Icons.check_circle_rounded
                  : Icons.info_outline_rounded,
              color: const Color(0xFF26A69A),
              size: 26,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                result!.predictedCrowd.toLowerCase() != 'high'
                    ? 'No alternatives needed for this place.'
                    : 'No same-category alternatives available.',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F8FF),
        borderRadius: BorderRadius.circular(24),
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
              Icon(Icons.explore_rounded, color: Color(0xFF1565C0)),
              SizedBox(width: 8),
              Text(
                'Alternative Locations',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF263238),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Try these alternatives based on lower or suitable crowd levels.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          ...result!.alternatives.map((alt) {
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFDCEEFF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF90CAF9),
                  width: 1.2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            capitalizeWords(alt.place),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: crowdColor(alt.predictedCrowd),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          alt.predictedCrowd.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _alternativeInfoChip(
                          icon: Icons.category_rounded,
                          label: alt.category,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _alternativeInfoChip(
                          icon: Icons.calendar_month_rounded,
                          label: alt.month,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _alternativeInfoChip(
                    icon: Icons.thermostat_rounded,
                    label: 'Temperature: ${alt.temperature}',
                    fullWidth: true,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => openGoogleMaps(alt.place),
                      icon: const Icon(Icons.navigation_rounded),
                      label: const Text('Navigate with Google Maps'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _alternativeInfoChip({
    required IconData icon,
    required String label,
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF26A69A)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey,
              ),
              overflow: TextOverflow.ellipsis,
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
                      const SizedBox(height: 16),
                      buildAlternativesSection(),
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
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  // Get current location
  Future<String> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return "Location services are disabled.";
    }

    // Check permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return "Location permissions are denied";
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return "Location permissions are permanently denied";
    }

    // Get position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return "${position.latitude},${position.longitude}";
  }

  // Make phone call
  Future<void> makePhoneCall(String number) async {
    final Uri uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // Send SMS with location
  Future<void> sendSMS(String message, String number) async {
    final Uri uri = Uri(
      scheme: 'sms',
      path: number,
      queryParameters: <String, String>{'body': message},
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // SOS button action
  void handleSOS(BuildContext context) async {
    String location = await getCurrentLocation();
    String message =
        "EMERGENCY! Need police help.\nMy location: https://maps.google.com/?q=$location";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("SOS Emergency"),
        content: const Text("Call Police at 119 and send your location?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close popup
              await makePhoneCall("119"); // Open dialer
              await sendSMS(message, "119"); // Open SMS with location
            },
            child: const Text("Call Now"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Emergency Contacts"), backgroundColor: Colors.red),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // SOS Button
          ElevatedButton.icon(
            onPressed: () => handleSOS(context),
            icon: const Icon(Icons.warning, color: Colors.white),
            label: const Text(
              "SOS EMERGENCY",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 20),

          // Emergency Cards
          const EmergencyCard(
            title: "Police Emergency",
            icon: Icons.local_police,
            phone: "119",
            color: Colors.blue,
          ),
          const EmergencyCard(
            title: "Ambulance",
            icon: Icons.local_hospital,
            phone: "1990",
            color: Colors.red,
          ),
          const EmergencyCard(
            title: "Traffic Police",
            icon: Icons.traffic,
            phone: "0112431718",
            color: Colors.orange,
          ),
          const EmergencyCard(
            title: "Women & Child Protection",
            icon: Icons.woman,
            phone: "1938",
            color: Colors.purple,
          ),
          const EmergencyCard(
            title: "Flood Rescue / Disaster",
            icon: Icons.water_damage,
            phone: "117",
            color: Colors.teal,
          ),
        ],
      ),
    );
  }
}

// Emergency Card
class EmergencyCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String phone;
  final Color color;

  const EmergencyCard({
    super.key,
    required this.title,
    required this.icon,
    required this.phone,
    required this.color,
  });

  Future<void> makePhoneCall(String number) async {
    final Uri uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.15),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        trailing: IconButton(
          icon: const Icon(Icons.call, color: Colors.green),
          onPressed: () => makePhoneCall(phone),
        ),
      ),
    );
  }
}

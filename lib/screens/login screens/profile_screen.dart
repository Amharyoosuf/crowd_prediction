import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_gate.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> logout(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AuthGate()),
              (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final String userEmail = user?.email ?? "User";

    return Scaffold(
      backgroundColor: Colors.grey[50], // Light, clean background
      body: CustomScrollView(
        slivers: [
          // 1. Sleek Header with Rounded Corners
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: Colors.deepPurple,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple, Colors.indigo],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    const CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person, size: 45, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      userEmail,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Profile Actions Grouped in Cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Account Settings"),
                  _buildProfileCard(
                    children: [
                      _buildProfileTile(Icons.person_outline, "Edit Profile", null),
                      const Divider(height: 1),
                      _buildProfileTile(Icons.notifications_none, "Notifications", null),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Crowd Insights"),
                  _buildProfileCard(
                    children: [
                      _buildProfileTile(Icons.history, "My Predictions", null),
                      const Divider(height: 1),
                      _buildProfileTile(Icons.bookmark_outline, "Saved Places", null),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // 3. Destructive Action Button (Logout)
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () => logout(context),
                      icon: const Icon(Icons.logout, color: Colors.redAccent),
                      label: const Text(
                        "Sign Out",
                        style: TextStyle(color: Colors.redAccent, fontSize: 16),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.redAccent.withOpacity(0.3)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets for Clean Code ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildProfileCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildProfileTile(IconData icon, String title, VoidCallback? onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple[400]),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
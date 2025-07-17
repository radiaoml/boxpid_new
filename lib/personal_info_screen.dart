import 'package:flutter/material.dart';

class PersonalInfoScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const PersonalInfoScreen({Key? key, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color mainGreen = const Color(0xff92B61B);

    return Scaffold(
      backgroundColor: mainGreen,
      appBar: AppBar(
        backgroundColor: mainGreen,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: const Icon(Icons.arrow_back, color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: mainGreen.withOpacity(0.1),
                  child: Icon(Icons.person, size: 60, color: mainGreen),
                ),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: mainGreen,
                  child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                )
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Personal information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildTextField(
              icon: Icons.person,
              hint: 'Name',
              initialValue: userData['fullName'] ?? 'Ahmed',
              mainGreen: mainGreen,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              icon: Icons.email,
              hint: 'Email',
              initialValue: userData['email'] ?? 'ahmedtest@gmail.com',
              mainGreen: mainGreen,
            ),
            const SizedBox(height: 16),
            _buildPasswordField(mainGreen),
            const SizedBox(height: 16),
            _buildTextField(
              icon: Icons.location_on,
              hint: 'City',
              initialValue: userData['city'] ?? 'Casablanca',
              mainGreen: mainGreen,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.arrow_forward, color: Colors.white),
                label: const Text('Save', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required IconData icon,
    required String hint,
    required String initialValue,
    required Color mainGreen,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: hint,
        prefixIcon: Icon(icon, color: mainGreen),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: mainGreen.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: mainGreen),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildPasswordField(Color mainGreen) {
    return TextFormField(
      obscureText: true,
      initialValue: '12345678',
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: Icon(Icons.visibility_off, color: mainGreen),
        suffixIcon: const Icon(Icons.arrow_forward_ios, size: 16),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: mainGreen.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: mainGreen),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

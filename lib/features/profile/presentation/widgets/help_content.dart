import 'package:flutter/material.dart';

class HelpContent extends StatelessWidget {
  const HelpContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSearchBar(),
        const SizedBox(height: 24),
        _buildSection(
          title: 'Frequently Asked Questions',
          children: [
            _buildFaqItem(
              question: 'How do I reset my password?',
              answer: 'To reset your password, go to the login screen and tap on "Forgot Password". Follow the instructions sent to your email.',
            ),
            _buildFaqItem(
              question: 'How do I enable biometric login?',
              answer: 'Go to Settings > Security and enable Biometric Authentication. Make sure your device has fingerprint or face recognition set up.',
            ),
            _buildFaqItem(
              question: 'How do I change my currency?',
              answer: 'Navigate to Settings > General > Currency and select your preferred currency from the list.',
            ),
          ],
        ),
        _buildSection(
          title: 'Contact Support',
          children: [
            _buildContactItem(
              title: 'Email Support',
              subtitle: 'support@metrowealth.com',
              icon: Icons.email_outlined,
              onTap: () {
                // Launch email client
              },
            ),
            _buildContactItem(
              title: 'Phone Support',
              subtitle: '+254 123 456 789',
              icon: Icons.phone_outlined,
              onTap: () {
                // Launch phone dialer
              },
            ),
            _buildContactItem(
              title: 'Live Chat',
              subtitle: 'Chat with our support team',
              icon: Icons.chat_outlined,
              onTap: () {
                // Launch chat interface
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search for help',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildFaqItem({
    required String question,
    required String answer,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(answer),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey.shade700),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
} 
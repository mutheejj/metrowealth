import 'package:flutter/material.dart';

class SettingsContent extends StatefulWidget {
  const SettingsContent({Key? key}) : super(key: key);

  @override
  State<SettingsContent> createState() => _SettingsContentState();
}

class _SettingsContentState extends State<SettingsContent> {
  String _selectedLanguage = 'English';
  String _selectedTheme = 'Light';
  String _selectedCurrency = 'KSh';
  bool _biometricEnabled = false;
  bool _emailNotifications = true;
  bool _smsNotifications = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSection(
          title: 'General',
          children: [
            _buildDropdownTile(
              title: 'Language',
              value: _selectedLanguage,
              icon: Icons.language,
              items: const ['English', 'Swahili', 'French'],
              onChanged: (value) {
                setState(() => _selectedLanguage = value!);
              },
            ),
            _buildDropdownTile(
              title: 'Theme',
              value: _selectedTheme,
              icon: Icons.palette_outlined,
              items: const ['Light', 'Dark', 'System'],
              onChanged: (value) {
                setState(() => _selectedTheme = value!);
              },
            ),
            _buildDropdownTile(
              title: 'Currency',
              value: _selectedCurrency,
              icon: Icons.currency_exchange,
              items: const ['KSh', 'USD', 'EUR', 'GBP'],
              onChanged: (value) {
                setState(() => _selectedCurrency = value!);
              },
            ),
          ],
        ),
        _buildSection(
          title: 'Security',
          children: [
            _buildSwitchTile(
              title: 'Biometric Authentication',
              subtitle: 'Use fingerprint to login',
              icon: Icons.fingerprint,
              value: _biometricEnabled,
              onChanged: (value) {
                setState(() => _biometricEnabled = value);
              },
            ),
          ],
        ),
        _buildSection(
          title: 'Notifications',
          children: [
            _buildSwitchTile(
              title: 'Email Notifications',
              subtitle: 'Receive email updates',
              icon: Icons.email_outlined,
              value: _emailNotifications,
              onChanged: (value) {
                setState(() => _emailNotifications = value);
              },
            ),
            _buildSwitchTile(
              title: 'SMS Notifications',
              subtitle: 'Receive SMS updates',
              icon: Icons.message_outlined,
              value: _smsNotifications,
              onChanged: (value) {
                setState(() => _smsNotifications = value);
              },
            ),
          ],
        ),
      ],
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

  Widget _buildDropdownTile({
    required String title,
    required String value,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
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
        trailing: DropdownButton<String>(
          value: value,
          items: items.map((String item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          underline: const SizedBox(),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: SwitchListTile(
        secondary: Icon(icon, color: Colors.grey.shade700),
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
} 
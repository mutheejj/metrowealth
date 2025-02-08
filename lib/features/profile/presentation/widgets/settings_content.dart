import 'package:flutter/material.dart';
import 'package:metrowealth/core/constants/app_colors.dart';

class SettingsContent extends StatefulWidget {
  final VoidCallback? onSave;

  const SettingsContent({
    Key? key,
    this.onSave,
  }) : super(key: key);

  @override
  State<SettingsContent> createState() => _SettingsContentState();
}

class _SettingsContentState extends State<SettingsContent> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'USD';

  final List<String> _languages = ['English', 'Spanish', 'French', 'German'];
  final List<String> _currencies = [
    'USD', 'EUR', 'GBP', 'JPY', 'KSh',  // Added KSh to the list
  ];

  @override
  void initState() {
    super.initState();
    // Ensure initial values are in the lists
    if (!_languages.contains(_selectedLanguage)) {
      _selectedLanguage = _languages[0];
    }
    if (!_currencies.contains(_selectedCurrency)) {
      _selectedCurrency = _currencies[0];
    }
  }

  Future<void> _saveSettings() async {
    try {
      // TODO: Implement saving settings to database
      // await DatabaseService().updateUserSettings(
      //   userId,
      //   {
      //     'notifications': _notificationsEnabled,
      //     'darkMode': _darkModeEnabled,
      //     'language': _selectedLanguage,
      //     'currency': _selectedCurrency,
      //   },
      // );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onSave?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error saving settings'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSettingItem(
          'Notifications',
          Switch(
            value: _notificationsEnabled,
            onChanged: (value) => setState(() => _notificationsEnabled = value),
            activeColor: AppColors.primary,
          ),
        ),
        _buildSettingItem(
          'Dark Mode',
          Switch(
            value: _darkModeEnabled,
            onChanged: (value) => setState(() => _darkModeEnabled = value),
            activeColor: AppColors.primary,
          ),
        ),
        _buildSettingItem(
          'Language',
          DropdownButton<String>(
            value: _selectedLanguage,
            items: _languages.map((String language) {
              return DropdownMenuItem<String>(
                value: language,
                child: Text(language),
              );
            }).toList(),
            onChanged: (String? value) {
              if (value != null) {
                setState(() => _selectedLanguage = value);
              }
            },
          ),
        ),
        _buildSettingItem(
          'Currency',
          DropdownButton<String>(
            value: _selectedCurrency,
            items: _currencies.map((String currency) {
              return DropdownMenuItem<String>(
                value: currency,
                child: Text(currency),
              );
            }).toList(),
            onChanged: (String? value) {
              if (value != null) {
                setState(() => _selectedCurrency = value);
              }
            },
          ),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: _saveSettings,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
            backgroundColor: AppColors.primary,
          ),
          child: const Text('Save Settings'),
        ),
      ],
    );
  }

  Widget _buildSettingItem(String title, Widget trailing) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing,
        ],
      ),
    );
  }
} 
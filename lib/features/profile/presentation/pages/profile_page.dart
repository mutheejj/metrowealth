import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/edit_profile_content.dart';
import '../widgets/help_content.dart';
import '../widgets/security_content.dart';
import '../widgets/settings_content.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _currentSection = 'main'; // 'main', 'edit', 'security', 'settings', 'help'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB71C1C),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB71C1C),
        elevation: 0,
        leading: _currentSection != 'main'
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  setState(() => _currentSection = 'main');
                },
              )
            : null,
        title: Text(
          _getTitle(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              // Handle notifications
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          if (_currentSection == 'main') _buildProfileHeader(),
          const SizedBox(height: 30),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: _buildCurrentSection(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            image: const DecorationImage(
              image: AssetImage('assets/images/profile.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'John Smith',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          'ID: 25030024',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentSection() {
    switch (_currentSection) {
      case 'edit':
        return EditProfileContent(
          onSave: () {
            setState(() => _currentSection = 'main');
          },
        );
      case 'security':
        return SecurityContent(
          onSave: () {
            setState(() => _currentSection = 'main');
          },
        );
      case 'settings':
        return const SettingsContent();
      case 'help':
        return const HelpContent();
      default:
        return _buildMainMenu();
    }
  }

  Widget _buildMainMenu() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildMenuItem(
          icon: Icons.person_outline,
          title: 'Edit Profile',
          color: Colors.blue,
          onTap: () => setState(() => _currentSection = 'edit'),
        ),
        _buildMenuItem(
          icon: Icons.security,
          title: 'Security',
          color: Colors.blue,
          onTap: () => setState(() => _currentSection = 'security'),
        ),
        _buildMenuItem(
          icon: Icons.settings,
          title: 'Setting',
          color: Colors.blue,
          onTap: () => setState(() => _currentSection = 'settings'),
        ),
        _buildMenuItem(
          icon: Icons.help_outline,
          title: 'Help',
          color: Colors.blue,
          onTap: () => setState(() => _currentSection = 'help'),
        ),
        _buildMenuItem(
          icon: Icons.logout,
          title: 'Logout',
          color: Colors.blue,
          onTap: () {
            // Handle logout
          },
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTitle() {
    switch (_currentSection) {
      case 'edit':
        return 'Edit Profile';
      case 'security':
        return 'Security';
      case 'settings':
        return 'Settings';
      case 'help':
        return 'Help & Support';
      default:
        return 'Profile';
    }
  }
} 
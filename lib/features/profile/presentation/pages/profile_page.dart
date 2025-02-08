import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:metrowealth/core/services/database_service.dart';
import 'package:metrowealth/features/auth/data/models/user_model.dart';

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
  String _currentSection = 'main';
  final DatabaseService _databaseService = DatabaseService();
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() => _isLoading = true);
      final userId = _databaseService.currentUserId;
      if (userId != null) {
        final user = await _databaseService.getUserProfile(userId);
        setState(() => _currentUser = user);
      }
    } catch (e) {
      _showErrorSnackBar('Error loading profile');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: _buildCurrentSection(),
    );
  }

  Widget _buildCurrentSection() {
    switch (_currentSection) {
      case 'edit':
        return EditProfileContent(
          user: _currentUser,
          onSave: _handleProfileUpdate,
        );
      case 'security':
        return SecurityContent(onSave: () {
          setState(() => _currentSection = 'main');
        });
      case 'settings':
        return const SettingsContent();
      case 'help':
        return const HelpContent();
      default:
        return _buildMainProfile();
    }
  }

  Widget _buildMainProfile() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 30),
          _buildProfileMenu(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundColor: Color(0xFFB71C1C),
          child: Icon(Icons.person, size: 50, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Text(
          _currentUser?.fullName ?? 'User',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          _currentUser?.email ?? '',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileMenu() {
    return Column(
      children: [
        _buildMenuItem(
          icon: Icons.edit,
          title: 'Edit Profile',
          onTap: () => setState(() => _currentSection = 'edit'),
        ),
        _buildMenuItem(
          icon: Icons.security,
          title: 'Security',
          onTap: () => setState(() => _currentSection = 'security'),
        ),
        _buildMenuItem(
          icon: Icons.settings,
          title: 'Settings',
          onTap: () => setState(() => _currentSection = 'settings'),
        ),
        _buildMenuItem(
          icon: Icons.help_outline,
          title: 'Help & Support',
          onTap: () => setState(() => _currentSection = 'help'),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: Colors.grey[100],
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFB71C1C)),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Future<void> _handleProfileUpdate(UserModel updatedUser) async {
    try {
      await _databaseService.createUserProfile(updatedUser);
      setState(() {
        _currentUser = updatedUser;
        _currentSection = 'main';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error updating profile');
      }
    }
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
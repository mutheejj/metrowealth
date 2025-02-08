import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:metrowealth/core/services/database_service.dart';
import 'package:metrowealth/features/auth/data/models/user_model.dart';
import 'package:metrowealth/core/constants/app_colors.dart';
import 'package:metrowealth/features/auth/data/repositories/auth_repository.dart';
import 'package:metrowealth/features/navigation/presentation/pages/main_navigation.dart';
import 'package:metrowealth/features/auth/presentation/pages/splash_screen.dart';
import 'package:metrowealth/features/auth/presentation/pages/welcome_screen.dart';
import 'package:metrowealth/features/auth/presentation/pages/login_page.dart';
import 'package:metrowealth/features/home/presentation/pages/home_page.dart';
import 'package:metrowealth/features/categories/presentation/pages/categories_page.dart';
import 'package:metrowealth/features/transactions/presentation/pages/transactions_page.dart';
import 'package:metrowealth/features/analysis/presentation/pages/analysis_page.dart';

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
  int _selectedIndex = 4; // Set to 4 for profile tab

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
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentSection != 'main' 
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _currentSection = 'main';
                });
              },
            )
          : null,
        title: Text(
          _getTitle(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                child: _buildCurrentSection(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home_outlined,
                  isSelected: _selectedIndex == 0,
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  },
                ),
                _buildNavItem(
                  icon: Icons.category_outlined,
                  isSelected: _selectedIndex == 1,
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const CategoriesPage()),
                    );
                  },
                ),
                _buildNavItem(
                  icon: Icons.receipt_long_outlined,
                  isSelected: _selectedIndex == 2,
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const TransactionsPage()),
                    );
                  },
                ),
                _buildNavItem(
                  icon: Icons.analytics_outlined,
                  isSelected: _selectedIndex == 3,
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const AnalysisPage()),
                    );
                  },
                ),
                _buildNavItem(
                  icon: Icons.person_outline,
                  isSelected: _selectedIndex == 4,
                  onTap: () {}, // Already on profile page
                ),
              ],
            ),
          ),
        ),
      ),
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
    return SingleChildScrollView(
      child: Column(
        children: [
          // Profile Picture and Name
          const CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/images/profile.jpeg'),
          ),
          const SizedBox(height: 16),
          Text(
            _currentUser?.fullName ?? 'John Smith',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'ID: ${_currentUser?.id ?? '25030024'}',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 30),

          // Menu Items
          _buildProfileMenuItem(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            color: Colors.blue,
            onTap: () => setState(() => _currentSection = 'edit'),
          ),
          _buildProfileMenuItem(
            icon: Icons.security,
            title: 'Security',
            color: Colors.blue,
            onTap: () => setState(() => _currentSection = 'security'),
          ),
          _buildProfileMenuItem(
            icon: Icons.settings,
            title: 'Setting',
            color: Colors.blue,
            onTap: () => setState(() => _currentSection = 'settings'),
          ),
          _buildProfileMenuItem(
            icon: Icons.help_outline,
            title: 'Help',
            color: Colors.blue,
            onTap: () => setState(() => _currentSection = 'help'),
          ),
          _buildProfileMenuItem(
            icon: Icons.logout,
            title: 'Logout',
            color: Colors.blue,
            onTap: () async {
              try {
                await AuthRepository().signOut();
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                    (route) => false,
                  );
                }
              } catch (e) {
                if (mounted) {
                  _showErrorSnackBar('Error signing out');
                }
              }
            },
          ),
          const SizedBox(height: 20),
          _buildProfileMenuItem(
            icon: Icons.delete_forever,
            title: 'Delete Account',
            color: Colors.red,
            onTap: _handleDeleteAccount,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 15),
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
              color: Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleProfileUpdate(UserModel user) async {
    try {
      await _databaseService.updateUserProfile(user);
      setState(() {
        _currentUser = user;
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

  Future<void> _handleDeleteAccount() async {
    final passwordController = TextEditingController();
    
    final bool? confirmPassword = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Please enter your password to delete your account. This action cannot be undone.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );

    if (confirmPassword == true) {
      try {
        // First verify the password and get user credentials
        await AuthRepository().verifyPassword(password: passwordController.text);
        
        // Then delete Firestore data
        await _databaseService.deleteUserAccount();
        
        // Finally delete the auth account and navigate
        await AuthRepository().deleteAccount(password: passwordController.text);

        if (mounted) {
          // Navigate to login page
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackBar(e.toString());
        }
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

  Widget _buildNavItem({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : const Color(0xFF757575),
          size: 24,
        ),
      ),
    );
  }
} 
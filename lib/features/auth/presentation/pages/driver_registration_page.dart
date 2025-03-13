import 'package:flutter/material.dart';
import 'package:metrowealth/core/constants/app_colors.dart';
import 'package:metrowealth/features/auth/presentation/widgets/custom_button.dart';
import 'package:metrowealth/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:metrowealth/features/home/presentation/pages/home_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class DriverRegistrationPage extends StatefulWidget {
  final String userId;
  
  const DriverRegistrationPage({super.key, required this.userId});

  @override
  State<DriverRegistrationPage> createState() => _DriverRegistrationPageState();
}

class _DriverRegistrationPageState extends State<DriverRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;
  File? _profileImage;

  // Personal Details
  final _phoneController = TextEditingController();
  final _nextOfKinNameController = TextEditingController();
  final _nextOfKinPhoneController = TextEditingController();
  String _maritalStatus = 'Single';
  final _addressController = TextEditingController();
  
  // Vehicle Details
  final _numberPlateController = TextEditingController();
  final _routeController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _vehicleModelController = TextEditingController();

  final List<String> _maritalStatusOptions = [
    'Single',
    'Married',
    'Divorced',
    'Widowed'
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _phoneController.dispose();
    _nextOfKinNameController.dispose();
    _nextOfKinPhoneController.dispose();
    _addressController.dispose();
    _numberPlateController.dispose();
    _routeController.dispose();
    _licenseNumberController.dispose();
    _vehicleModelController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Future<String?> _uploadProfileImage() async {
    if (_profileImage == null) return null;
    
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('driver_profiles')
          .child('${widget.userId}.jpg');
          
      await ref.putFile(_profileImage!);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading profile image: $e');
      return null;
    }
  }

  Future<void> _submitDriverDetails() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String? profileImageUrl = await _uploadProfileImage();

      final driverData = {
        'personalDetails': {
          'phone': _phoneController.text,
          'nextOfKin': {
            'name': _nextOfKinNameController.text,
            'phone': _nextOfKinPhoneController.text,
          },
          'maritalStatus': _maritalStatus,
          'address': _addressController.text,
          'profileImageUrl': profileImageUrl,
        },
        'vehicleDetails': {
          'numberPlate': _numberPlateController.text,
          'route': _routeController.text,
          'licenseNumber': _licenseNumberController.text,
          'vehicleModel': _vehicleModelController.text,
        },
        'registrationCompleted': true,
        'registrationDate': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('drivers')
          .doc(widget.userId)
          .set(driverData, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      debugPrint('Error submitting driver details: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to complete registration. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildPersonalDetailsPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personal Details',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : null,
                child: _profileImage == null
                    ? const Icon(Icons.person, size: 50, color: Colors.grey)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  radius: 18,
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                    onPressed: _pickImage,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        CustomTextField(
          controller: _phoneController,
          label: 'Phone Number',
          hint: 'Enter your phone number',
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your phone number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _nextOfKinNameController,
          label: 'Next of Kin Name',
          hint: 'Enter next of kin name',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _nextOfKinPhoneController,
          label: 'Next of Kin Phone',
          hint: 'Enter next of kin phone number',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _maritalStatus,
          decoration: const InputDecoration(
            labelText: 'Marital Status',
            border: OutlineInputBorder(),
          ),
          items: _maritalStatusOptions.map((String status) {
            return DropdownMenuItem(
              value: status,
              child: Text(status),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _maritalStatus = newValue!;
            });
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _addressController,
          label: 'Residential Address',
          hint: 'Enter your address',
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildVehicleDetailsPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vehicle Details',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 24),
        CustomTextField(
          controller: _numberPlateController,
          label: 'Vehicle Number Plate',
          hint: 'Enter vehicle number plate',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter vehicle number plate';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _vehicleModelController,
          label: 'Vehicle Model',
          hint: 'Enter vehicle model',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter vehicle model';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _routeController,
          label: 'Route',
          hint: 'Enter your regular route',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your route';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _licenseNumberController,
          label: 'Driver License Number',
          hint: 'Enter your license number',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your license number';
            }
            return null;
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              )
            : null,
        title: Text(
          'Driver Registration',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: (_currentPage + 1) / 2,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (page) {
                      setState(() => _currentPage = page);
                    },
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      SingleChildScrollView(child: _buildPersonalDetailsPage()),
                      SingleChildScrollView(child: _buildVehicleDetailsPage()),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  CustomButton(
                    text: _currentPage == 0 ? 'Next' : 'Complete Registration',
                    onPressed: () {
                      if (_currentPage == 0) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _submitDriverDetails();
                      }
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
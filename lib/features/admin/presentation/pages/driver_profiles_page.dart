import 'package:flutter/material.dart';
import 'package:metrowealth/core/constants/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DriverProfilesPage extends StatefulWidget {
  const DriverProfilesPage({super.key});

  @override
  State<DriverProfilesPage> createState() => _DriverProfilesPageState();
}

class _DriverProfilesPageState extends State<DriverProfilesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterBy = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search drivers...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() => _searchQuery = value);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      DropdownButton<String>(
                        value: _filterBy,
                        items: [
                          const DropdownMenuItem(
                            value: 'all',
                            child: Text('All Drivers'),
                          ),
                          const DropdownMenuItem(
                            value: 'active',
                            child: Text('Active'),
                          ),
                          const DropdownMenuItem(
                            value: 'inactive',
                            child: Text('Inactive'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _filterBy = value!);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('drivers')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final drivers = snapshot.data!.docs
                    .map((doc) => {
                          'id': doc.id,
                          ...doc.data() as Map<String, dynamic>
                        })
                    .where((driver) {
                  final searchLower = _searchQuery.toLowerCase();
                  final personalDetails =
                      driver['personalDetails'] as Map<String, dynamic>;
                  final vehicleDetails =
                      driver['vehicleDetails'] as Map<String, dynamic>;

                  return searchLower.isEmpty ||
                      personalDetails['phone']
                          .toString()
                          .toLowerCase()
                          .contains(searchLower) ||
                      vehicleDetails['numberPlate']
                          .toString()
                          .toLowerCase()
                          .contains(searchLower);
                }).toList();

                if (drivers.isEmpty) {
                  return const Center(
                    child: Text('No drivers found'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: drivers.length,
                  itemBuilder: (context, index) {
                    final driver = drivers[index];
                    final personalDetails =
                        driver['personalDetails'] as Map<String, dynamic>;
                    final vehicleDetails =
                        driver['vehicleDetails'] as Map<String, dynamic>;
                    final registrationDate =
                        (driver['registrationDate'] as Timestamp).toDate();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundImage: personalDetails['profileImageUrl'] !=
                                  null
                              ? NetworkImage(
                                  personalDetails['profileImageUrl'] as String)
                              : null,
                          child: personalDetails['profileImageUrl'] == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(
                          vehicleDetails['numberPlate'] as String,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Registered: ${DateFormat('MMM d, yyyy').format(registrationDate)}',
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoSection('Personal Details', [
                                  'Phone: ${personalDetails['phone']}',
                                  'Next of Kin: ${personalDetails['nextOfKin']['name']}',
                                  'Next of Kin Phone: ${personalDetails['nextOfKin']['phone']}',
                                  'Marital Status: ${personalDetails['maritalStatus']}',
                                  'Address: ${personalDetails['address']}',
                                ]),
                                const SizedBox(height: 16),
                                _buildInfoSection('Vehicle Details', [
                                  'Number Plate: ${vehicleDetails['numberPlate']}',
                                  'Route: ${vehicleDetails['route']}',
                                  'License Number: ${vehicleDetails['licenseNumber']}',
                                  'Vehicle Model: ${vehicleDetails['vehicleModel']}',
                                ]),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.edit),
                                      label: const Text('Edit'),
                                      onPressed: () {
                                        // TODO: Implement edit functionality
                                      },
                                    ),
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.block),
                                      label: const Text('Suspend'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      onPressed: () {
                                        // TODO: Implement suspend functionality
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<String> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        ...details.map((detail) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(detail),
            )),
      ],
    );
  }
}
class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? mobileNumber;
  final DateTime? dateOfBirth;
  final DateTime createdAt;
  final DateTime? lastUpdated;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.mobileNumber,
    this.dateOfBirth,
    required this.createdAt,
    this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'mobileNumber': mobileNumber,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'createdAt': createdAt,
      'lastUpdated': lastUpdated,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      mobileNumber: map['mobileNumber'],
      dateOfBirth: map['dateOfBirth'] != null 
          ? DateTime.parse(map['dateOfBirth']) 
          : null,
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      lastUpdated: map['lastUpdated']?.toDate(),
    );
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? mobileNumber,
    DateTime? dateOfBirth,
    DateTime? createdAt,
    DateTime? lastUpdated,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
} 
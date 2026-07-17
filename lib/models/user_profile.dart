class UserProfile {
  final String uid;
  final String email;
  final String? displayName;
  final double? heightCm;
  final double? weightKg;
  final int? dailyStepGoal;
  final DateTime createdAt;

  UserProfile({
    required this.uid,
    required this.email,
    this.displayName,
    this.heightCm,
    this.weightKg,
    this.dailyStepGoal,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'dailyStepGoal': dailyStepGoal,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] as String? ?? '',
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String?,
      heightCm: (map['heightCm'] as num?)?.toDouble(),
      weightKg: (map['weightKg'] as num?)?.toDouble(),
      dailyStepGoal: map['dailyStepGoal'] as int?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
    );
  }
}

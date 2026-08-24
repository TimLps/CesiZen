class UserRole {
  final int id;
  final String name;
  final String label;
  const UserRole({required this.id, required this.name, required this.label});

  factory UserRole.fromJson(Map<String, dynamic> j) => UserRole(
        id: j['id_role'] as int,
        name: j['name'] as String,
        label: j['label'] as String,
      );

  bool get isAdmin => name == 'admin';
}

class UserStateInfo {
  final int id;
  final String name;
  final String label;
  const UserStateInfo({
    required this.id,
    required this.name,
    required this.label,
  });

  factory UserStateInfo.fromJson(Map<String, dynamic> j) => UserStateInfo(
        id: j['id_user_state'] as int,
        name: j['name'] as String,
        label: j['label'] as String,
      );
}

class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? city;
  final DateTime? birthDate;
  final UserRole? role;
  final UserStateInfo? state;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.city,
    this.birthDate,
    this.role,
    this.state,
    this.createdAt,
  });

  String get fullName => '$firstName $lastName';
  bool get isAdmin => role?.isAdmin ?? false;
  bool get isActive => state?.name == 'active';

  factory User.fromJson(Map<String, dynamic> j) => User(
        id: j['id_user'] as int,
        firstName: j['first_name'] as String,
        lastName: j['last_name'] as String,
        email: j['email'] as String,
        city: j['city'] as String?,
        birthDate: j['birth_date'] != null
            ? DateTime.tryParse(j['birth_date'] as String)
            : null,
        role: j['role'] != null
            ? UserRole.fromJson(j['role'] as Map<String, dynamic>)
            : null,
        state: j['user_state'] != null
            ? UserStateInfo.fromJson(j['user_state'] as Map<String, dynamic>)
            : null,
        createdAt: j['created_at'] != null
            ? DateTime.tryParse(j['created_at'] as String)
            : null,
      );
}

class UserRole {
  final int id;
  final String name;
  final String label;

  const UserRole({required this.id, required this.name, required this.label});

  factory UserRole.fromJson(Map<String, dynamic> json) => UserRole(
        id: json['id_role'] as int,
        name: json['name'] as String,
        label: json['label'] as String,
      );

  bool get isAdmin => name == 'admin';
}

class UserStateInfo {
  final int id;
  final String name;
  final String label;

  const UserStateInfo({required this.id, required this.name, required this.label});

  factory UserStateInfo.fromJson(Map<String, dynamic> json) => UserStateInfo(
        id: json['id_user_state'] as int,
        name: json['name'] as String,
        label: json['label'] as String,
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

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.city,
    this.birthDate,
    this.role,
    this.state,
  });

  String get fullName => '$firstName $lastName';
  bool get isAdmin => role?.isAdmin ?? false;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id_user'] as int,
        firstName: json['first_name'] as String,
        lastName: json['last_name'] as String,
        email: json['email'] as String,
        city: json['city'] as String?,
        birthDate: json['birth_date'] != null
            ? DateTime.tryParse(json['birth_date'] as String)
            : null,
        role: json['role'] != null
            ? UserRole.fromJson(json['role'] as Map<String, dynamic>)
            : null,
        state: json['user_state'] != null
            ? UserStateInfo.fromJson(json['user_state'] as Map<String, dynamic>)
            : null,
      );
}

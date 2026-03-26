class CafeUser {
  final int id;
  final String email;
  final String name;
  final String role;

  CafeUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });

  bool get isAdmin => role == 'admin';
  bool get isApproved => role == 'approved';
  bool get isPending => role == 'pending';

  factory CafeUser.fromJson(Map<String, dynamic> json) {
    return CafeUser(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      role: json['role'],
    );
  }
}

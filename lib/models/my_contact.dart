class MyContact {
  final int? id;
  final String name;
  final String phone;
  final String email;
  final String? imagePath;

  MyContact({
    this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'imagePath': imagePath,
    };
  }

  factory MyContact.fromMap(Map<String, dynamic> map) {
    return MyContact(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      email: map['email'],
      imagePath: map['imagePath'],
    );
  }
}
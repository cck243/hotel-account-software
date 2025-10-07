class User {
  String uid;
  String email;
  String? phoneNumber;
  String role; // owner, manager
  String businessName;
  
  User({
    required this.uid,
    required this.email,
    this.phoneNumber,
    this.role = 'owner',
    required this.businessName,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'businessName': businessName,
    };
  }
  
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'],
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      role: map['role'] ?? 'owner',
      businessName: map['businessName'],
    );
  }
}

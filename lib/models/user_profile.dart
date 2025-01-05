class UserProfile {
  final String uid;
  final String displayName;
  final String email;
  String? photoUrl;
  String? bio;
  String? phoneNumber;
  Map<String, dynamic>? preferences;

  UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.bio,
    this.phoneNumber,
    this.preferences,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'bio': bio,
      'phoneNumber': phoneNumber,
      'preferences': preferences,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'],
      displayName: map['displayName'],
      email: map['email'],
      photoUrl: map['photoUrl'],
      bio: map['bio'],
      phoneNumber: map['phoneNumber'],
      preferences: map['preferences'],
    );
  }
} 
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String? bio;
  final List<String> photoUrls;
  final DateTime birthDate;
  final String gender;
  final String interestedIn;
  final bool isProfileComplete;
  final DateTime createdAt;
  final DateTime lastActive;

  // Profile prompts (Hinge-style)
  final Map<String, String> promptResponses;

  // "Roots" section
  final String? hometown;
  final String? faithTradition;
  final String? nonNegotiableValue;

  // "Home & Future" section
  final String? kidsPreference;
  final String? relocationPreference;
  final String? lifestylePreference;
  final String? faithLevel;

  // Matching preferences
  final Map<String, dynamic> matchingPreferences;
  final String? politicalAlignment;
  final bool? traditionalRoles;
  final bool isPremium;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.bio,
    required this.photoUrls,
    required this.birthDate,
    required this.gender,
    required this.interestedIn,
    required this.isProfileComplete,
    required this.createdAt,
    required this.lastActive,
    required this.promptResponses,
    this.hometown,
    this.faithTradition,
    this.nonNegotiableValue,
    this.kidsPreference,
    this.relocationPreference,
    this.lifestylePreference,
    this.faithLevel,
    required this.matchingPreferences,
    this.politicalAlignment,
    this.traditionalRoles,
    this.isPremium = false,
  });

  // Factory constructor to create a UserModel from a Firebase document
  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      bio: data['bio'],
      photoUrls: List<String>.from(data['photoUrls'] ?? []),
      birthDate: (data['birthDate'] as Timestamp).toDate(),
      gender: data['gender'] ?? '',
      interestedIn: data['interestedIn'] ?? '',
      isProfileComplete: data['isProfileComplete'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastActive: (data['lastActive'] as Timestamp).toDate(),
      promptResponses: Map<String, String>.from(data['promptResponses'] ?? {}),
      hometown: data['hometown'],
      faithTradition: data['faithTradition'],
      nonNegotiableValue: data['nonNegotiableValue'],
      kidsPreference: data['kidsPreference'],
      relocationPreference: data['relocationPreference'],
      lifestylePreference: data['lifestylePreference'],
      faithLevel: data['faithLevel'],
      matchingPreferences: Map<String, dynamic>.from(
        data['matchingPreferences'] ?? {},
      ),
      politicalAlignment: data['politicalAlignment'],
      traditionalRoles: data['traditionalRoles'],
      isPremium: data['isPremium'] ?? false,
    );
  }

  // Convert a UserModel to a map for storing in Firebase
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'bio': bio,
      'photoUrls': photoUrls,
      'birthDate': Timestamp.fromDate(birthDate),
      'gender': gender,
      'interestedIn': interestedIn,
      'isProfileComplete': isProfileComplete,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActive': Timestamp.fromDate(lastActive),
      'promptResponses': promptResponses,
      'hometown': hometown,
      'faithTradition': faithTradition,
      'nonNegotiableValue': nonNegotiableValue,
      'kidsPreference': kidsPreference,
      'relocationPreference': relocationPreference,
      'lifestylePreference': lifestylePreference,
      'faithLevel': faithLevel,
      'matchingPreferences': matchingPreferences,
      'politicalAlignment': politicalAlignment,
      'traditionalRoles': traditionalRoles,
      'isPremium': isPremium,
    };
  }

  // Create a copy of the UserModel with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? bio,
    List<String>? photoUrls,
    DateTime? birthDate,
    String? gender,
    String? interestedIn,
    bool? isProfileComplete,
    DateTime? createdAt,
    DateTime? lastActive,
    Map<String, String>? promptResponses,
    String? hometown,
    String? faithTradition,
    String? nonNegotiableValue,
    String? kidsPreference,
    String? relocationPreference,
    String? lifestylePreference,
    String? faithLevel,
    Map<String, dynamic>? matchingPreferences,
    String? politicalAlignment,
    bool? traditionalRoles,
    bool? isPremium,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      photoUrls: photoUrls ?? this.photoUrls,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      interestedIn: interestedIn ?? this.interestedIn,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      promptResponses: promptResponses ?? this.promptResponses,
      hometown: hometown ?? this.hometown,
      faithTradition: faithTradition ?? this.faithTradition,
      nonNegotiableValue: nonNegotiableValue ?? this.nonNegotiableValue,
      kidsPreference: kidsPreference ?? this.kidsPreference,
      relocationPreference: relocationPreference ?? this.relocationPreference,
      lifestylePreference: lifestylePreference ?? this.lifestylePreference,
      faithLevel: faithLevel ?? this.faithLevel,
      matchingPreferences: matchingPreferences ?? this.matchingPreferences,
      politicalAlignment: politicalAlignment ?? this.politicalAlignment,
      traditionalRoles: traditionalRoles ?? this.traditionalRoles,
      isPremium: isPremium ?? this.isPremium,
    );
  }

  // Helper method to calculate age from birthdate
  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}

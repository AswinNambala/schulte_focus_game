import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.displayName,
    super.photoUrl,
    required super.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    DateTime parsedDate;
    final createdAtRaw = map['createdAt'];
    if (createdAtRaw is Timestamp) {
      parsedDate = createdAtRaw.toDate();
    } else if (createdAtRaw is String) {
      parsedDate = DateTime.tryParse(createdAtRaw) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return UserModel(
      uid: uid,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? 'User',
      photoUrl: map['photoUrl'] as String?,
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      email: entity.email,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
      createdAt: entity.createdAt,
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class FriendRequest {
  final String id;
  final String senderId;
  final String receiverId;
  final String status;
  final DateTime sentAt;
  final String senderUsername;

  FriendRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.sentAt,
    required this.senderUsername,
  });

  factory FriendRequest.fromMap(Map<String, dynamic> data, String id) {
    return FriendRequest(
      id: id,
      senderId: data['senderId'],
      receiverId: data['receiverId'],
      status: data['status'],
      senderUsername: data['username'] ?? 'Unknown', // fallback
      sentAt: (data['sentAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'status': status,
      'sentAt': sentAt,
      'senderUsername': senderUsername,
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/friend_request.dart';

class FriendService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUserId => _auth.currentUser!.uid;

  // Send friend request
  Future<void> sendRequest(String receiverId, String senderUsername) async {
    // Check if a request already exists
    final existingRequest = await _firestore
        .collection('friend_requests')
        .where('senderId', isEqualTo: currentUserId)
        .where('receiverId', isEqualTo: receiverId)
        .where('status', isEqualTo: 'pending')
        .get();

    if (existingRequest.docs.isNotEmpty) {
      throw Exception('Friend request already sent');
    }

    // Check if the user is already friends
    final friends = await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('friends')
        .doc(receiverId)
        .get();

    if (friends.exists) {
      throw Exception('You are already friends with this user');
    }

    await _firestore.collection('friend_requests').add({
      'senderId': currentUserId,
      'senderUsername': senderUsername,
      'receiverId': receiverId,
      'status': 'pending',
      'sentAt': FieldValue.serverTimestamp(),
    });
  }

  // Stream of outgoing friend requests
  Stream<List<FriendRequest>> getOutgoingRequests() {
    return _firestore
        .collection('friend_requests')
        .where('senderId', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FriendRequest.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Stream of incoming friend requests
  Stream<List<FriendRequest>> getIncomingRequests() {
    return _firestore
        .collection('friend_requests')
        .where('receiverId', isEqualTo: currentUserId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FriendRequest.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Accept a friend request
  Future<void> acceptRequest(String requestId, String senderId) async {
    final batch = _firestore.batch();

    final requestRef = _firestore.collection('friend_requests').doc(requestId);

    final currentUserFriendsRef = _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('friends')
        .doc(senderId);

    final senderFriendsRef = _firestore
        .collection('users')
        .doc(senderId)
        .collection('friends')
        .doc(currentUserId);

    final timestamp = FieldValue.serverTimestamp();

    // 1. Mark request as accepted
    batch.update(requestRef, {'status': 'accepted'});

    // 2. Add each other to friends subcollections
    batch.set(currentUserFriendsRef, {
      'friendId': senderId,
      'addedAt': timestamp,
    });

    batch.set(senderFriendsRef, {
      'friendId': currentUserId,
      'addedAt': timestamp,
    });

    await batch.commit();
  }

  // Reject a friend request
  Future<void> rejectRequest(String requestId) async {
    await _firestore.collection('friend_requests').doc(requestId).update({
      'status': 'rejected',
    });
  }

  Stream<List<String>> getFriendIds() {
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('friends')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }
}

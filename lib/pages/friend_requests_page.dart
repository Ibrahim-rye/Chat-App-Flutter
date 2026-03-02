import 'package:flutter/material.dart';
import '../services/friend/friend_service.dart';
import '../models/friend_request.dart';

class FriendRequestsPage extends StatelessWidget {
  final FriendService _friendService = FriendService();

  FriendRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Friend Requests")),
      body: Column(
        children: [
          Expanded(child: _buildIncomingRequests()),
          const Divider(),
          Expanded(child: _buildOutgoingRequests()),
        ],
      ),
    );
  }

  // Incoming Requests with Accept/Reject
  Widget _buildIncomingRequests() {
    return StreamBuilder<List<FriendRequest>>(
      stream: _friendService.getIncomingRequests(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Text('Error loading requests');
        if (!snapshot.hasData) return const CircularProgressIndicator();

        final requests = snapshot.data!;
        if (requests.isEmpty) return const Text("No incoming requests");

        return ListView(
          children: requests.map((req) {
            return ListTile(
              title: Text("From: ${req.senderUsername}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () =>
                        _friendService.acceptRequest(req.id, req.senderId),
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear, color: Colors.red),
                    onPressed: () => _friendService.rejectRequest(req.id),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // Outgoing Requests (Sent)
  Widget _buildOutgoingRequests() {
    return StreamBuilder<List<FriendRequest>>(
      stream: _friendService.getOutgoingRequests(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Text('Error loading sent requests');
        if (!snapshot.hasData) return const CircularProgressIndicator();

        final requests = snapshot.data!;
        if (requests.isEmpty) return const Text("No requests sent");

        return ListView(
          children: requests.map((req) {
            return ListTile(
              title: Text(
                  "To: ${req.receiverId}"), // You could improve this by storing receiverUsername
              subtitle: Text("Status: ${req.status}"),
            );
          }).toList(),
        );
      },
    );
  }
}

import 'package:chatapp/components/my_drawer.dart';
import 'package:chatapp/components/user_tile.dart';
import 'package:chatapp/pages/chat_page.dart';
import 'package:chatapp/services/friend/friend_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/services/auth/auth_service.dart';
import 'package:chatapp/services/chat/chat_service.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  // chat and auth service

  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      drawer: const MyDrawer(),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: _buildUserList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddFriendDialog(context),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  // build a list of users except the current user
  Widget _buildUserList() {
    return StreamBuilder<List<String>>(
      stream: FriendService().getFriendIds(),
      builder: (context, friendSnapshot) {
        if (friendSnapshot.hasError) {
          return Text("Friend Error: ${friendSnapshot.error}");
        }

        if (!friendSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final friendIds = friendSnapshot.data!;

        return StreamBuilder(
          stream: _chatService.getUsersStream(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final users = snapshot.data!;
            final filteredUsers = users.where((userData) {
              return friendIds.contains(userData["id"]) &&
                  userData["email"] != _authService.getCurrentUser()!.email;
            }).toList();

            return ListView(
              children: filteredUsers
                  .map<Widget>(
                      (userData) => _buildUserListItem(userData, context))
                  .toList(),
            );
          },
        );
      },
    );
  }

  // build a individual list tile for user
  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
    // display all usrs except the current user
    if (userData["email"] != _authService.getCurrentUser()!.email) {
      return UserTile(
        text: userData['username'],
        onTap: () {
          // tap the user -> go to chat page
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  receiverEmail: userData["email"],
                  receiverID: userData["id"],
                ),
              ));
        },
      );
    } else {
      return Container();
    }
  }

  void _showAddFriendDialog(BuildContext context) {
    final usernameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Friend"),
        content: TextField(
          controller: usernameController,
          decoration: const InputDecoration(hintText: "Enter username"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final enteredUsername = usernameController.text.trim();

              if (enteredUsername.isEmpty) return;

              Navigator.pop(context); // close dialog

              // Fetch receiver info by username
              final query = await FirebaseFirestore.instance
                  .collection('users')
                  .where('username', isEqualTo: enteredUsername)
                  .get();

              if (query.docs.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("User not found")),
                );
                return;
              }

              final receiverDoc = query.docs.first;
              final receiverId = receiverDoc.id;

              // Get sender username
              final senderDoc = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .get();
              final senderUsername = senderDoc['username'];

              try {
                await FriendService().sendRequest(receiverId, senderUsername);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Friend request sent")),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            },
            child: const Text("Send"),
          ),
        ],
      ),
    );
  }
}

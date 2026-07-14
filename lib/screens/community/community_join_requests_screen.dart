import 'package:flutter/material.dart';
import 'package:quest/theme/theme.dart';

class CommunityJoinRequestsScreen extends StatefulWidget {
  final String communityId;
  const CommunityJoinRequestsScreen({super.key, required this.communityId});

  @override
  State<CommunityJoinRequestsScreen> createState() => _CommunityJoinRequestsScreenState();
}

class _CommunityJoinRequestsScreenState extends State<CommunityJoinRequestsScreen> {
  // Mock data for UI demonstration
  List<Map<String, dynamic>> _requests = [
    {'id': 'req1', 'userName': 'John Doe', 'status': 'PENDING'},
    {'id': 'req2', 'userName': 'Jane Smith', 'status': 'PENDING'},
  ];

  void _approveRequest(String reqId) {
    setState(() {
      _requests.removeWhere((req) => req['id'] == reqId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request approved')),
    );
  }

  void _rejectRequest(String reqId) {
    setState(() {
      _requests.removeWhere((req) => req['id'] == reqId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request rejected')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Requests'),
      ),
      body: _requests.isEmpty
          ? const Center(child: Text('No pending requests.'))
          : ListView.builder(
              itemCount: _requests.length,
              itemBuilder: (context, index) {
                final req = _requests[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.buttonColor.withOpacity(0.2),
                    child: Icon(Icons.person, color: AppTheme.buttonColor),
                  ),
                  title: Text(req['userName']),
                  subtitle: Text('Requested to join'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => _approveRequest(req['id']),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => _rejectRequest(req['id']),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

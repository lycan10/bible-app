import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/services/api_service.dart';
import 'package:quest/theme/theme.dart';
import 'package:quest/components/avatar.dart';

class CommunityJoinRequestsScreen extends StatefulWidget {
  final String communityId;
  const CommunityJoinRequestsScreen({super.key, required this.communityId});

  @override
  State<CommunityJoinRequestsScreen> createState() => _CommunityJoinRequestsScreenState();
}

class _CommunityJoinRequestsScreenState extends State<CommunityJoinRequestsScreen> {
  List<dynamic> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) return;

    try {
      final requests = await ApiService.fetchCommunityJoinRequests(token, widget.communityId);
      if (mounted) {
        setState(() {
          _requests = requests;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load requests: $e')),
        );
      }
    }
  }

  Future<void> _approveRequest(String reqId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) return;

    try {
      await ApiService.approveCommunityJoinRequest(token, widget.communityId, reqId);
      setState(() {
        _requests.removeWhere((req) => req['id'] == reqId);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request approved')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to approve request: $e')),
        );
      }
    }
  }

  Future<void> _rejectRequest(String reqId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) return;

    try {
      await ApiService.rejectCommunityJoinRequest(token, widget.communityId, reqId);
      setState(() {
        _requests.removeWhere((req) => req['id'] == reqId);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request rejected')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reject request: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Requests'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? const Center(child: Text('No pending requests.'))
              : ListView.builder(
                  itemCount: _requests.length,
                  itemBuilder: (context, index) {
                    final req = _requests[index];
                    final user = req['user'] ?? {};
                    final String userName = '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'.trim();
                    final String avatarUrl = user['avatarUrl'] ?? '';
                    
                    return ListTile(
                      leading: CustomAvatar(
                        radius: 20,
                        imageUrl: avatarUrl.isNotEmpty ? avatarUrl : null,
                      ),
                      title: Text(userName.isEmpty ? 'Unknown User' : userName),
                      subtitle: const Text('Requested to join'),
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

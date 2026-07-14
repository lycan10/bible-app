import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/components/messages/admin_message_card.dart';
import 'package:quest/components/titles/title_one.dart';
import 'package:quest/services/api_service.dart';
import 'package:hugeicons/hugeicons.dart';

class AdminMessageListScreen extends StatefulWidget {
  const AdminMessageListScreen({super.key});

  @override
  State<AdminMessageListScreen> createState() => _AdminMessageListScreenState();
}

class _AdminMessageListScreenState extends State<AdminMessageListScreen> {
  List<dynamic> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMessages();
    });
  }

  Future<void> _loadMessages() async {
    final auth = context.read<AuthProvider>();
    if (auth.token == null) return;

    setState(() => _isLoading = true);
    try {
      final response = await ApiService.fetchMyAdminMessages(auth.token!);
      if (mounted) {
        setState(() {
          _messages = response['data'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading admin messages: \$e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 15, left: 16, right: 16),
          child: Column(
            children: [
              TitleOne(
                leadingIcon: HugeIcons.strokeRoundedArrowLeft01,
                title: 'Messages',
                trailingIcon: HugeIcons.strokeRoundedMoreVertical,
                leadingIconTap: () => Navigator.pop(context),
                trailingIconTap: () {},
              ),
              const SizedBox(height: 25),
              Expanded(
                child:
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _messages.isEmpty
                        ? const Center(
                          child: Text("No messages found in your communities."),
                        )
                        : ListView.builder(
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            return AdminMessageCard(message: _messages[index]);
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import '../providers/feature_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/community_provider.dart';
import 'package:quest/theme/theme.dart';
import 'paywall_screen.dart';

class CreateCommunityScreen extends StatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  State<CreateCommunityScreen> createState() => _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends State<CreateCommunityScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _description = '';
  bool _isPrivate = false;

  final TextEditingController _guidelinesController = TextEditingController();

  final String _sampleGuidelines = '''1. Be respectful and kind to others.
2. No spam or self-promotion.
3. Keep discussions relevant to the community.
4. Harassment or hate speech will result in an immediate ban.
5. Respect everyone's privacy.''';

  @override
  void dispose() {
    _guidelinesController.dispose();
    super.dispose();
  }

  void _showSubscriptionRequiredModal() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppTheme.buttonColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.workspace_premium_rounded,
                    size: 40,
                    color: AppTheme.buttonColor,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Subscription Required',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Creating a community is a premium feature. Subscribe to unlock this and many more exclusive features.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.buttonColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PaywallScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'View Subscription Plans',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('Maybe Later'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSampleGuidelinesPreview() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sample Guidelines'),
          content: SingleChildScrollView(child: Text(_sampleGuidelines)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.buttonColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _guidelinesController.text = _sampleGuidelines;
                });
                Navigator.pop(context);
              },
              child: const Text('Adopt'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    // --- Subscription gate: check before hitting the API ---
    final subProvider = Provider.of<SubscriptionProvider>(context, listen: false);

    if (!subProvider.isSubscribed) {
      _showSubscriptionRequiredModal();
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) return;

    final guidelines = _guidelinesController.text;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Creating community...')),
    );

    try {
      await Provider.of<CommunityProvider>(context, listen: false)
          .createCommunity(token, {
        'name': _name,
        'description': _description,
        'isPrivate': _isPrivate,
        'guidelines': guidelines,
      });

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Community created successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Fallback: backend also blocks unsubscribed users
      if (e.toString().contains('You must be subscribed') ||
          e.toString().contains('subscribed')) {
        _showSubscriptionRequiredModal();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create community: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Community')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Community Name',
                  ),
                  validator:
                      (val) => val == null || val.isEmpty ? 'Required' : null,
                  onSaved: (val) => _name = val!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator:
                      (val) => val == null || val.isEmpty ? 'Required' : null,
                  onSaved: (val) => _description = val!,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Private Community'),
                  subtitle: const Text(
                    'Users must request to join and be approved by an admin.',
                  ),
                  value: _isPrivate,
                  activeThumbColor: AppTheme.buttonColor,
                  onChanged: (val) {
                    setState(() {
                      _isPrivate = val;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Community Guidelines',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: _showSampleGuidelinesPreview,
                      style: TextButton.styleFrom(
                        backgroundColor: AppTheme.buttonColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Preview Sample'),
                    ),
                  ],
                ),
                TextFormField(
                  controller: _guidelinesController,
                  decoration: const InputDecoration(
                    hintText:
                        'Enter rules and guidelines for your community here...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.buttonColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Create'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/buttons/gradient_button.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final _messageController = TextEditingController();

  Future<void> _contact() async {
    final uri = Uri.parse(
      'mailto:support@giggl.app?subject=Support Request&body=${Uri.encodeComponent(_messageController.text)}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'How can we help?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 24),
            ExpansionTile(
              title: const Text('How do I book a service?'),
              children: const [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Browse services, select one, choose your event date, and pay the advance to confirm.',
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: const Text('What is the advance payment?'),
              children: const [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'A 25% advance secures your booking. The remaining amount is paid after service completion.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AppTextField(
              controller: _messageController,
              label: 'Your Message',
              hint: 'Describe your issue...',
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            GradientButton(
              label: 'Contact Support',
              onPressed: _contact,
            ),
          ],
        ),
      ),
    );
  }
}

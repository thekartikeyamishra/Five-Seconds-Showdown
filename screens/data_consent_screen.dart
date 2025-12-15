// lib/screens/data_consent_screen.dart
// ETHICAL DATA COLLECTION CONSENT SCREEN
// Fully transparent, GDPR/DPDP compliant

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class DataConsentScreen extends StatefulWidget {
  const DataConsentScreen({Key? key}) : super(key: key);

  @override
  State<DataConsentScreen> createState() => _DataConsentScreenState();
}

class _DataConsentScreenState extends State<DataConsentScreen> {
  bool _consentToDataCollection = false;
  bool _consentToVoiceRecording = false;
  bool _hasReadTerms = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Collection Consent'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Icon(
              Icons.privacy_tip,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            
            Text(
              'Help Us Build Better AI',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Your participation can help create more inclusive AI for India and the world.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // What we collect
            _buildSection(
              title: '📊 What We Collect',
              content: _buildWhatWeCollect(),
            ),
            
            const SizedBox(height: 24),
            
            // Why we collect
            _buildSection(
              title: '🎯 Why We Collect',
              content: _buildWhyWeCollect(),
            ),
            
            const SizedBox(height: 24),
            
            // How we protect
            _buildSection(
              title: '🔒 How We Protect Your Privacy',
              content: _buildHowWeProtect(),
            ),
            
            const SizedBox(height: 24),
            
            // Your rights
            _buildSection(
              title: '⚖️ Your Rights',
              content: _buildYourRights(),
            ),
            
            const SizedBox(height: 32),
            
            // Consent checkboxes
            _buildConsentCheckboxes(),
            
            const SizedBox(height: 24),
            
            // Action buttons
            _buildActionButtons(),
            
            const SizedBox(height: 16),
            
            // Footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSection({
    required String title,
    required Widget content,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }
  
  Widget _buildWhatWeCollect() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBulletPoint('Your game answers (text or voice)'),
        _buildBulletPoint('Whether your answer was correct or wrong'),
        _buildBulletPoint('Time taken to answer'),
        _buildBulletPoint('Language and accent information (if voice is used)'),
        _buildBulletPoint('General device information (NOT device ID)'),
        const SizedBox(height: 12),
        Text(
          'We DO NOT collect:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red[700],
          ),
        ),
        _buildBulletPoint('Your name, email, or phone number', isNegative: true),
        _buildBulletPoint('Your exact location', isNegative: true),
        _buildBulletPoint('Device ID or any tracking identifiers', isNegative: true),
        _buildBulletPoint('Any personally identifiable information', isNegative: true),
      ],
    );
  }
  
  Widget _buildWhyWeCollect() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'To build better AI that:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        _buildBulletPoint('Understands Indian accents and Hinglish'),
        _buildBulletPoint('Works for low-resource languages'),
        _buildBulletPoint('Handles code-switching (mixing languages)'),
        _buildBulletPoint('Serves diverse users across India'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            '🌍 Your data helps make AI more inclusive for everyone!',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildHowWeProtect() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBulletPoint('All personal information is automatically removed (anonymized)'),
        _buildBulletPoint('Data is encrypted and stored securely'),
        _buildBulletPoint('You can delete your data anytime'),
        _buildBulletPoint('Data is only used for AI training, nothing else'),
        _buildBulletPoint('Compliant with India\'s DPDP Act'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.verified_user, color: Colors.green[700]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your privacy is our top priority',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.green[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildYourRights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'You have the right to:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        _buildBulletPoint('Say NO without any impact on gameplay'),
        _buildBulletPoint('Change your mind anytime'),
        _buildBulletPoint('Request deletion of your data'),
        _buildBulletPoint('Know exactly how your data is used'),
        _buildBulletPoint('Withdraw consent at any time'),
      ],
    );
  }
  
  Widget _buildBulletPoint(String text, {bool isNegative = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isNegative ? '❌' : '•',
            style: TextStyle(
              fontSize: 20,
              color: isNegative ? Colors.red : Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isNegative ? Colors.red[700] : Colors.black87,
                decoration: isNegative ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildConsentCheckboxes() {
    return Column(
      children: [
        CheckboxListTile(
          value: _consentToDataCollection,
          onChanged: (value) {
            setState(() {
              _consentToDataCollection = value ?? false;
            });
          },
          title: const Text(
            'I consent to anonymized data collection',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: const Text(
            'Your answers and gameplay data (fully anonymized)',
          ),
          controlAffinity: ListTileControlAffinity.leading,
        ),
        
        CheckboxListTile(
          value: _consentToVoiceRecording,
          onChanged: (value) {
            setState(() {
              _consentToVoiceRecording = value ?? false;
            });
          },
          title: const Text(
            'I consent to voice recording (optional)',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: const Text(
            'If you use voice mode, help train better voice AI',
          ),
          controlAffinity: ListTileControlAffinity.leading,
        ),
        
        const SizedBox(height: 16),
        
        CheckboxListTile(
          value: _hasReadTerms,
          onChanged: (value) {
            setState(() {
              _hasReadTerms = value ?? false;
            });
          },
          title: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black87),
              children: [
                const TextSpan(text: 'I have read and understood the '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => _showPrivacyPolicy(),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Terms of Service',
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => _showTermsOfService(),
                ),
              ],
            ),
          ),
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ],
    );
  }
  
  Widget _buildActionButtons() {
    final canAccept = _consentToDataCollection && _hasReadTerms;
    
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: canAccept ? _acceptConsent : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Accept & Continue',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: _declineConsent,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'No Thanks, Just Play',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildFooter() {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 8),
        Text(
          'This consent can be changed anytime in Settings',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Questions? Contact: support@fivesecondsshowdown.com',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  void _acceptConsent() {
    // Save consent
    Navigator.pop(context, {
      'data_collection': _consentToDataCollection,
      'voice_recording': _consentToVoiceRecording,
    });
  }
  
  void _declineConsent() {
    // User can still play, just no data collection
    Navigator.pop(context, {
      'data_collection': false,
      'voice_recording': false,
    });
  }
  
  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Privacy Policy content here...\n\n'
            'We take your privacy seriously...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'Terms of Service content here...\n\n'
            'By using this app...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
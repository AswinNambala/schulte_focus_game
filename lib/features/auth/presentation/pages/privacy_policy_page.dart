import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Policy for Schulte Focus',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: November 2026',
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
            const Divider(height: 32),
            _buildSection(
              '1. Overview',
              'Schulte Focus ("we", "our", or "the app") is committed to protecting your privacy. This policy explains what information is collected, how it is used, and how your data is safeguarded.',
            ),
            _buildSection(
              '2. Data We Collect',
              '• Authentication Information: When you create an account via Email/Password or Google Sign-In, we store your email address, display name, user ID, and profile picture (if provided).\n'
              '• Gameplay & Session Data: To provide focus training metrics, we record completion times, error counts, levels reached, game modes, and reaction times per tap.\n'
              '• Technical Diagnostics: We use Firebase Crashlytics and Firebase Analytics to monitor crash reports and app performance in order to improve stability on Android devices.',
            ),
            _buildSection(
              '3. How We Use Data',
              '• To authenticate your access and synchronize your training progress across devices.\n'
              '• To compute cognitive focus metrics, historical trends, and adaptive difficulty levels.\n'
              '• To identify and fix app crashes, performance bottlenecks, and bugs.',
            ),
            _buildSection(
              '4. Data Security & Storage',
              'All user data is encrypted in transit using standard HTTPS/TLS and stored in Google Cloud Firestore. Access to your personal gameplay sessions is strictly restricted to your authenticated user account via Firebase Security Rules.',
            ),
            _buildSection(
              '5. Account & Data Deletion',
              'You have the complete right to request the deletion of your account and all associated data at any time. You can delete your account directly inside the app from the Profile/Settings screen, or by contacting developer support.',
            ),
            _buildSection(
              '6. Contact Us',
              'If you have any questions about this Privacy Policy or your personal data, please contact developer support at uanachu8271@gmail.com.',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}

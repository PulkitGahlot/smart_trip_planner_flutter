import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itinerary_ai/core/theme/app_theme.dart';
import 'package:itinerary_ai/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userEmail = authState.currentUserEmail ?? 'guest@email.com';
    final userName = userEmail.split('@')[0];
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'G';
    
    // Mock data for token usage
    const requestTokens = 100.0;
    const responseTokens = 75.0;
    const totalCost = 0.07;
    const maxTokens = 1000.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                  )
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppTheme.primaryColor,
                        child: Text(userInitial, style: const TextStyle(color: Colors.white, fontSize: 20)),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${userName[0].toUpperCase()}${userName.substring(1)} S.', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20)),
                          Text(userEmail, style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      )
                    ],
                  ),
                  const Divider(height: 30),
                  _buildUsageRow('Request Tokens', requestTokens, maxTokens, context, AppTheme.primaryColor),
                  const SizedBox(height: 16),
                  _buildUsageRow('Response Tokens', responseTokens, maxTokens, context, Colors.redAccent),
                  const Divider(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Cost', style: Theme.of(context).textTheme.bodyLarge),
                      Text('\$${totalCost.toStringAsFixed(2)} USD', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),
            TextButton.icon(
              onPressed: () => ref.read(authProvider.notifier).logout(context),
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Log Out', style: TextStyle(color: Colors.red)),
              style: TextButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.1),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageRow(String title, double value, double max, BuildContext context, Color progressColor) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Theme.of(context).textTheme.bodyLarge),
            Text('${value.toInt()}/${max.toInt()}', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: value / max,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          borderRadius: BorderRadius.circular(10),
          minHeight: 8,
        ),
      ],
    );
  }
}
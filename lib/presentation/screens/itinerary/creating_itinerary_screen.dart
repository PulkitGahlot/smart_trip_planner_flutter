import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:itinerary_ai/core/theme/app_theme.dart';
import 'package:itinerary_ai/data/gemini_ai_service.dart';
import 'package:itinerary_ai/presentation/providers/auth_provider.dart';

class CreatingItineraryScreen extends ConsumerStatefulWidget {
  final String prompt;
  const CreatingItineraryScreen({super.key, required this.prompt});

  @override
  ConsumerState<CreatingItineraryScreen> createState() =>
      _CreatingItineraryScreenState();
}

class _CreatingItineraryScreenState extends ConsumerState<CreatingItineraryScreen> {
  @override
  void initState() {
    super.initState();
    _generateItinerary();
  }

  Future<void> _generateItinerary() async {
    try {
      final result = await GeminiAiService().generateItinerary(widget.prompt);
      if (mounted) {
        context.replace('/itinerary-created', extra: {
          'itinerary': result['itinerary'],
          'wasVoiceInput': false,
          'originalPrompt': widget.prompt // Passing the original prompt forward
        });
      }
    } catch (e) {
      // Handling error, show a snackbar and pop
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Something went wrong. Try creating again")));
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userEmail = authState.currentUserEmail ?? 'guest@email.com';
    final userName = userEmail.split('@')[0];
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'G';
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
                      onTap: () => context.push('/profile'),
                      child: CircleAvatar(
                        backgroundColor: AppTheme.primaryColor,
                        child: Text(userInitial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text('Creating Itinerary...', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28)),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppTheme.primaryColor,),
                    SizedBox(height: 20),
                    Text(
                      'Curating a perfect plan for you...', 
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black,),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.forum_outlined),
                onPressed: null, // Disabled
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(16)),
                ),
                label: const Text('Follow up to refine'),
              ),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: null, // Disabled
              icon: const Icon(Icons.save_alt, color: Colors.grey),
              label: const Text('Save Offline', style: TextStyle(color: Colors.grey)),
            )
          ],
        ),
      ),
    );
  }
}
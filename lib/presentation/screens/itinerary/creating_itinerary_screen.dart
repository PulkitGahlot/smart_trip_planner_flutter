import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:itinerary_ai/data/gemini_ai_service.dart';

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
          'originalPrompt': widget.prompt // Pass the original prompt forward
        });
      }
    } catch (e) {
      // Handle error, maybe show a snackbar and pop
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
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
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text('Curating a perfect plan for you...', textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: null, // Disabled
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade300),
                child: const Text('Follow up to refine'),
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
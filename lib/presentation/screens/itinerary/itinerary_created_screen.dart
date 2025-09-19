import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:itinerary_ai/core/theme/app_theme.dart';
import 'package:itinerary_ai/presentation/providers/auth_provider.dart';
import 'package:itinerary_ai/presentation/providers/chat_provider.dart';
import 'package:itinerary_ai/presentation/providers/saved_itinerary_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ItineraryCreatedScreen extends ConsumerWidget {
  final Map<String, dynamic> itinerary;
  final bool wasVoiceInput;
  final String originalPrompt;

  const ItineraryCreatedScreen({
    super.key,
    required this.itinerary,
    required this.wasVoiceInput,
    required this.originalPrompt,
  });



  Future<void> _launchMaps(BuildContext context, double lat, double lon) async {
    final Uri googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lon');
    final Uri appleMapsUrl = Uri.parse('https://maps.apple.com/?q=$lat,$lon');
    
    try {
      if (Platform.isIOS) {
        await launchUrl(appleMapsUrl);
      } else {
        await launchUrl(googleMapsUrl);
      }
    } catch (e) {
      if(context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch maps.'))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final day = itinerary['days'][0];
    final mapInfo = itinerary['mapInfo'];
    final authState = ref.watch(authProvider);
    final userEmail = authState.currentUserEmail ?? 'guest@email.com';
    final userName = userEmail.split('@')[0];
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'G';
    final double latitude = (mapInfo['latitude'] as num).toDouble();
    final double longitude = (mapInfo['longitude'] as num).toDouble();


    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Itinerary Created 🏖️", 
              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28,),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(day['title'], style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      ...List.generate((day['items'] as List).length, (index) {
                        final item = day['items'][index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ', style: TextStyle(fontSize: 16)),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(text: '${item['type']}: ', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black)),
                                      TextSpan(text: item['description'], style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () =>_launchMaps(context, latitude, longitude),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12)
                          ),
                          child: Column(
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.pin_drop, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text(
                                    'Open in maps', 
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold, 
                                      color: Colors.blue, 
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.blue,
                                      decorationThickness: 2,
                                      )
                                    ),
                                  SizedBox(width: 4),
                                  Icon(Icons.open_in_new, size: 16,color: Colors.blue,)
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${mapInfo['origin']} to ${mapInfo['destination']}',
                                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Text("|"),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Text(mapInfo['duration'], style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),),
                                ],
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.forum_outlined),
                onPressed: () {
                  // Create a plain text version of the itinerary to start the chat
                  final initialAiResponse = (itinerary['days'][0]['items'] as List)
                      .map((item) => "• ${item['type']}: ${item['description']}")
                      .join('\n');

                  final initialUserPrompt = originalPrompt; // A trick to get the prompt

                  context.push('/chat', extra: {
                    'userPrompt': initialUserPrompt,
                    'aiResponse': initialAiResponse
                  });
                },
                style: ElevatedButton.styleFrom(
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(16)),
                ),
                label: const Text('Follow up to refine', style: TextStyle(fontSize: 18),),
              ),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () {
                final initialAiResponse = (itinerary['days'][0]['items'] as List)
                                .map((item) => "• ${item['type']}: ${item['description']}")
                                .join('\n');
                  final fullAiResponse = "Day 1: ${itinerary['days'][0]['title']}\n$initialAiResponse";
                  
                  final tempChatState = ChatState(messages: [
                    ChatMessage(text: originalPrompt, isUser: true),
                    ChatMessage(text: fullAiResponse, isUser: false),
                  ]);

                  ref.read(savedItineraryProvider.notifier).saveItineraryFromChatState(tempChatState, originalPrompt);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Itinerary saved offline!'))
                  );
              },
              icon: const Icon(Icons.save_alt,color: Colors.black,),
              label: const Text('Save Offline', style: TextStyle(color: Colors.black),),
            )
          ],
        ),
      ),
    );
  }
}
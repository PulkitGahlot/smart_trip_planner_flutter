import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:itinerary_ai/core/theme/app_theme.dart';
import 'package:itinerary_ai/presentation/providers/auth_provider.dart';
import 'package:itinerary_ai/presentation/providers/saved_itinerary_provider.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _promptController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;
  bool _wasVoiceInput = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  void _startListening() async {
    await _speechToText.listen(onResult: (result) {
      setState(() {
        _promptController.text = result.recognizedWords;
        _wasVoiceInput = true;
      });
    });
    setState(() => _isListening = true);
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() => _isListening = false);
  }

  @override
  void dispose() {
    _promptController.dispose();
    _speechToText.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userEmail = authState.currentUserEmail ?? 'guest@email.com';
    final userName = userEmail.split('@')[0];
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'G';
    final savedItineraries = ref.watch(savedItineraryProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hey ${userName[0].toUpperCase()}${userName.substring(1)} 👋',
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primaryColor,
                        ),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/profile'),
                    child: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor,
                      radius: 22,
                      child: Text(userInitial,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20)),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 50),
              Text(
                "What's your vision\nfor this trip?",
                style: Theme.of(context)
                    .textTheme
                    .displayLarge!
                    .copyWith(fontWeight: FontWeight.w900),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryColor, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 10,
                    )
                  ],
                ),
                child: TextField(
                  controller: _promptController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText:
                        '7 days in Bali next April, 3 people, mid-range budget, wanted to explore less populated areas, it should be a peaceful trip!',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(_isListening ? Icons.mic_off : Icons.mic,
                          color: AppTheme.primaryColor),
                      onPressed: _speechEnabled
                          ? (_isListening ? _stopListening : _startListening)
                          : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_promptController.text.isNotEmpty) {
                      context.push('/creating-itinerary',
                          extra: _promptController.text);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Lets start by adding an outline to your trip in that box!'))
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 5,
                    shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(16))),
                  ),
                  child: const Text(
                    'Create My Itinerary',
                    style: TextStyle(fontSize: 19),
                  ),
                ),
              ),
              const SizedBox(height: 60),
              Text(
                'Offline Saved Itineraries',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 20),
              savedItineraries.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('No saved itineraries yet.',
                            style: Theme.of(context).textTheme.bodyMedium),
                      ))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: savedItineraries.length,
                      itemBuilder: (context, index) {
                        final conversation = savedItineraries[index];
                        final title =
                            conversation.initialPrompt.split('\n').first;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Dismissible(
                            key: Key(conversation.id),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) {
                              ref
                                  .read(savedItineraryProvider.notifier)
                                  .deleteItinerary(conversation.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Itinerary deleted.')),
                              );
                            },
                            background: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12)
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),
                            child: Card(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadiusGeometry.circular(21),
                                side: BorderSide(width: 1,color: Colors.grey.withOpacity(0.2))
                              ),
                              elevation: 0.7,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.circle_rounded,
                                  color: Color(0xff35af8d),
                                  shadows: [
                                    BoxShadow(
                                      blurRadius: 18,
                                      spreadRadius: 7,
                                      color: Color(0xff6ce7c5)
                                    )
                                  ],
                                  size: 14,
                                ),
                                title: Text(title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                onTap: () => context.push(
                                    '/saved-itinerary-view',
                                    extra: conversation),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
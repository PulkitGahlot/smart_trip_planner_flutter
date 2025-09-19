// lib/presentation/screens/itinerary/follow_up_chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:itinerary_ai/core/theme/app_theme.dart';
import 'package:itinerary_ai/presentation/providers/auth_provider.dart';
import 'package:itinerary_ai/presentation/providers/chat_provider.dart';
import 'package:itinerary_ai/presentation/providers/saved_itinerary_provider.dart';

class FollowUpChatScreen extends ConsumerStatefulWidget {
  final Map<String, String> initialData;
  const FollowUpChatScreen({super.key, required this.initialData});

  @override
  ConsumerState<FollowUpChatScreen> createState() => _FollowUpChatScreenState();
}

class _FollowUpChatScreenState extends ConsumerState<FollowUpChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Use WidgetsBinding to initialize chat after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatProvider.notifier).initializeChat(
            widget.initialData['userPrompt']!,
            widget.initialData['aiResponse']!,
          );
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  void _sendMessage() {
    if (_textController.text.trim().isEmpty) return;
    ref.read(chatProvider.notifier).sendMessage(_textController.text.trim());
    _textController.clear();
    // Scroll to the bottom after sending a message
    Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    
    final authState = ref.watch(authProvider);
    final userEmail = authState.currentUserEmail ?? 'guest@email.com';
    final userName = userEmail.split('@')[0];
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'G';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialData['userPrompt'] ?? 'Chat'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
                      onTap: () => context.push('/profile'),
                      child: CircleAvatar(
                        backgroundColor: AppTheme.primaryColor,
                        child: Text(userInitial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: chatState.messages.length,
              itemBuilder: (context, index) {
                final message = chatState.messages[index];
                return _buildChatBubble(message,userInitial);
              },
            ),
          ),
          _buildChatInputField(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message, String userInitial) {
    if (message.isLoading) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(vertical: 8),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.message_outlined,
                    color: Colors.amber,
                    ),
                  SizedBox(
                    width: 6,
                  ),
                  Text("Itinera AI", style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black)),
                ],
              ),
              const SizedBox(height: 8),
              if (message.isError)
                Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(child: Text("Oops! The LLM failed to generate answer. Please regenerate.", style: const TextStyle(color: Colors.red))),
                  ],
                )
              else
                Row(
                  children: [
                    Icon(Icons.circle_outlined, color: Colors.amber, size: 18,),
                    SizedBox(
                      width: 12,
                    ),
                    Text(
                      "Thinking..."
                    ),
                  ],
                ),
                _buildActionButton(Icons.refresh, "Regenerate", () {
                  ref.read(chatProvider.notifier).regenerateLastResponse();
                })
            ],
          ),
        ),
      );
    }

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: message.isUser ? Border.all(color: Colors.grey.shade300) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                message.isUser ? CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  radius: 12,
                  child: Text(userInitial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ) : Icon(
                  Icons.message_outlined,
                  color: Colors.amber,
                  ),
                SizedBox(
                  width: 6,
                ),
                Text(message.isUser ? "You" : "Itinera AI", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
              ],
            ),
            const SizedBox(height: 8),
            if (message.isError)
              Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(child: Text("Oops! The LLM failed to generate answer. Please regenerate.", style: const TextStyle(color: Colors.red))),
                ],
              )
            else
              Text(message.text, style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),),
            const SizedBox(height: 12),
            const Divider(thickness: 0.4,),
            SizedBox(
              height: 10,
            ),
            _buildActionButtons(message),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(ChatMessage message) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (message.isError)
           _buildActionButton(Icons.refresh, "Regenerate", () {
              ref.read(chatProvider.notifier).regenerateLastResponse();
           })
        else ...[
          _buildActionButton(Icons.copy, "Copy", () {
            Clipboard.setData(ClipboardData(text: message.text));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard!')));
          }),
          if (!message.isUser) ...[
            const SizedBox(width: 16),
            _buildActionButton(Icons.save_alt, "Save Offline", () {
              final chatState = ref.read(chatProvider);
              final initialPrompt = widget.initialData['userPrompt']!;
              ref.read(savedItineraryProvider.notifier).saveItineraryFromChatState(chatState, initialPrompt);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chat saved offline!')));
            }),
            const SizedBox(width: 16),
            _buildActionButton(Icons.refresh, "Regenerate", () {
               ref.read(chatProvider.notifier).regenerateLastResponse();
            }),
          ]
        ]
      ],
    );
  }
  
  Widget _buildActionButton(IconData icon, String label, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade700),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildChatInputField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Follow up to refine',
                  fillColor: Colors.white,
                  suffixIcon: const Icon(Icons.mic, color: AppTheme.primaryColor,size: 28,),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: BorderSide(color: AppTheme.primaryColor, width: 1.7),
                  ),
                  filled: true,
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: AppTheme.primaryColor, width: 1.7),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: AppTheme.primaryColor, width: 1.7),
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.primaryColor,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
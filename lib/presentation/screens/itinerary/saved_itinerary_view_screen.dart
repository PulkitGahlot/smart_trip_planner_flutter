import 'package:flutter/material.dart';
import 'package:itinerary_ai/data/saved_conversation.dart';

class SavedItineraryViewScreen extends StatelessWidget {
  final SavedConversation conversation;
  const SavedItineraryViewScreen({super.key, required this.conversation});

  @override
  Widget build(BuildContext context) {
    // Extract the first line of the prompt for the title
    final title = conversation.initialPrompt.split('\n').first;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView.builder(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.all(16),
        itemCount: conversation.messages.length,
        itemBuilder: (context, index) {
          final message = conversation.messages[index];
          return _buildChatBubble(context, message);
        },
      ),
    );
  }

  Widget _buildChatBubble(BuildContext context, SavedChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.white : Colors.amber.shade50,
          borderRadius: BorderRadius.circular(16),
          border: message.isUser ? Border.all(color: Colors.grey.shade300) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message.isUser ? "You" : "Itinera AI", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(message.text),
          ],
        ),
      ),
    );
  }
}
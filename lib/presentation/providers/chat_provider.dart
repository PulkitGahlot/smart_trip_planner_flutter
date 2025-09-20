import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itinerary_ai/data/gemini_ai_service.dart';

// Represents a single message in the chat
class ChatMessage {
  final String text;
  final bool isUser;
  final bool isLoading;
  final bool isError;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.isLoading = false,
    this.isError = false,
  });
}

// The state for our chat screen
class ChatState {
  final List<ChatMessage> messages;
  ChatState({this.messages = const []});

  ChatState copyWith({List<ChatMessage>? messages}) {
    return ChatState(messages: messages ?? this.messages);
  }
}

// The StateNotifier that manages the chat state
class ChatNotifier extends StateNotifier<ChatState> {
  final GeminiAiService _aiService = GeminiAiService();

  ChatNotifier() : super(ChatState());

  // Called when the chat screen is first entered
  void initializeChat(String userPrompt, String initialAiResponse) {
    state = ChatState(messages: [
      ChatMessage(text: userPrompt, isUser: true),
      ChatMessage(text: initialAiResponse, isUser: false),
    ]);
  }

  // Called when the user sends a new message
  Future<void> sendMessage(String text) async {
    // Add the user's message to the list immediately
    state = state.copyWith(messages: [
      ...state.messages,
      ChatMessage(text: text, isUser: true)
    ]);

    // Adding a loading indicator for the AI's response
    state = state.copyWith(
        messages: [...state.messages, ChatMessage(text: '', isUser: false, isLoading: true)]);

    try {
      // Getting the full chat history to provide context to the AI
      final chatHistory = state.messages.map((m) => m.text).join('\n');
      final result = await _aiService.refineItinerary(chatHistory);
      final aiResponse = result['itinerary']['response'] as String;

      // Removing the loading indicator and add the AI's actual response
      state.messages.removeLast();
      state = state.copyWith(
          messages: [...state.messages, ChatMessage(text: aiResponse, isUser: false)]);

    } catch (e) {
      // Removing the loading indicator and show an error message instead
      state.messages.removeLast();
      state = state.copyWith(messages: [
        ...state.messages,
        ChatMessage(text: e.toString(), isUser: false, isError: true)
      ]);
    }
  }

  // Called when the user wants to regenerate the last response
  Future<void> regenerateLastResponse() async {
    if (state.messages.length < 2) return; // Cannot regenerate if there's no history

    // Removing the last AI message (whether it was a success or error)
    state.messages.removeLast();
    // Re-run the sendMessage logic with the last user prompt
    final lastUserMessage = state.messages.last.text;
    state.messages.removeLast(); // Removing the last user message to avoid duplication
    
    await sendMessage(lastUserMessage);
  }
}

// The provider that the UI will interact with
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});
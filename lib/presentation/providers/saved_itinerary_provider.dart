import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:itinerary_ai/data/saved_conversation.dart';
import 'package:itinerary_ai/presentation/providers/auth_provider.dart';
import 'package:itinerary_ai/presentation/providers/chat_provider.dart';

class SavedItineraryNotifier extends StateNotifier<List<SavedConversation>> {
  final Ref _ref;
  SavedItineraryNotifier(this._ref) : super([]) {
    // Listen for changes in authentication state.
    _ref.listen(authProvider, (previous, next) {
      // When the user logs in (email goes from null to non-null) or
      // logs out (email goes from non-null to null), reload the itineraries.
      loadItineraries();
    }, fireImmediately: true); // fireImmediately runs this once on startup
  }

  Box<SavedConversation>? _getItinerariesBox() {
    final sessionBox = Hive.box('session');
    final userId = sessionBox.get('userId');
    if (userId == null) return null;
    final boxName = 'itineraries_$userId';
    return Hive.isBoxOpen(boxName) ? Hive.box<SavedConversation>(boxName) : null;
  }

  Future<void> loadItineraries() async {
    final box = _getItinerariesBox();
    if (box != null) {
      state = box.values.toList().reversed.toList();
    } else {
      state = [];
    }
  }

  Future<void> saveItineraryFromChatState(ChatState chatState, String initialPrompt) async {
    final box = _getItinerariesBox();
    if (box == null) {
      return;
    }

    final newConversation = SavedConversation()
      ..initialPrompt = initialPrompt
      ..messages = chatState.messages.map((msg) {
        return SavedChatMessage()
          ..text = msg.text
          ..isUser = msg.isUser;
      }).toList();

    await box.put(newConversation.id, newConversation);
    await loadItineraries(); // Reload to update the UI
  }

  Future<void> deleteItinerary(String id) async {
    final box = _getItinerariesBox();
    if (box == null) return;
    await box.delete(id);
    await loadItineraries(); // Reload to update the UI
  }
}

final savedItineraryProvider = StateNotifierProvider<SavedItineraryNotifier, List<SavedConversation>>((ref) {
  return SavedItineraryNotifier(ref);
});
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'saved_conversation.g.dart';

@HiveType(typeId: 3)
class SavedConversation extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String initialPrompt;

  @HiveField(2)
  late List<SavedChatMessage> messages;

  SavedConversation() {
    id = const Uuid().v4();
  }
}

@HiveType(typeId: 4)
class SavedChatMessage extends HiveObject {
  @HiveField(0)
  late String text;

  @HiveField(1)
  late bool isUser;
}
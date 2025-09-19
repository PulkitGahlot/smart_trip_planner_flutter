// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_conversation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedConversationAdapter extends TypeAdapter<SavedConversation> {
  @override
  final int typeId = 3;

  @override
  SavedConversation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedConversation()
      ..id = fields[0] as String
      ..initialPrompt = fields[1] as String
      ..messages = (fields[2] as List).cast<SavedChatMessage>();
  }

  @override
  void write(BinaryWriter writer, SavedConversation obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.initialPrompt)
      ..writeByte(2)
      ..write(obj.messages);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedConversationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SavedChatMessageAdapter extends TypeAdapter<SavedChatMessage> {
  @override
  final int typeId = 4;

  @override
  SavedChatMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedChatMessage()
      ..text = fields[0] as String
      ..isUser = fields[1] as bool;
  }

  @override
  void write(BinaryWriter writer, SavedChatMessage obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.text)
      ..writeByte(1)
      ..write(obj.isUser);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedChatMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

import 'package:hive/hive.dart';

part 'itinerary.g.dart';

@HiveType(typeId: 0)
class Itinerary extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late List<Day> days;

  @HiveField(3)
  late String initialPrompt;
  
  @HiveField(4)
  late String mapUrl; // To store map related data
}

@HiveType(typeId: 1)
class Day extends HiveObject {
  @HiveField(0)
  late String title;

  @HiveField(1)
  late List<Item> items;
}

@HiveType(typeId: 2)
class Item extends HiveObject {
  @HiveField(0)
  late String time;
  
  @HiveField(1)
  late String description;

  @HiveField(2)
  late String type; // e.g., 'Morning', 'Transfer', 'Accommodation'
}
import "package:isar/isar.dart";

part "habit.g.dart";

@Collection()
class Habit {
  Id id = Isar.autoIncrement;

  late String name;

  List<DateTime> completedDays = [
    // DateTime(year, month, day),
    // DateTime(2024, 1, 1),
    // DateTime(2024,1,2),
  ];
}

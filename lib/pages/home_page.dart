import 'package:flutter/material.dart';
import 'package:habittracker/components/my_drawer.dart';
import 'package:habittracker/components/my_habit_tile.dart';
import 'package:habittracker/components/my_heat_map.dart';
import 'package:habittracker/database/habit_database.dart';
import 'package:habittracker/models/habit.dart';
import 'package:habittracker/util/habit_util.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    // read existing habits on app startup
    Provider.of<HabitDatabase>(context, listen: false).readHabits();

    super.initState();
  }

  final TextEditingController textController = TextEditingController();

  void createNewHabit() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: textController,
                decoration:
                    const InputDecoration(hintText: "Create a new habit"),
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    String newHabitName = textController.text;

                    context.read<HabitDatabase>().addHabit(newHabitName);

                    Navigator.pop(context);

                    textController.clear();
                  },
                  child: const Text("Save"),
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);

                    textController.clear();
                  },
                  child: const Text("Cancel"),
                ),
              ],
            ));
  }

  void checkHabitOnOff(bool? value, Habit habit) {
    // update habit completion status
    if (value != null) {
      context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
    }
  }

  void editHabitBox(Habit habit) {
    textController.text = habit.name;

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: textController,
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    String newHabitName = textController.text;

                    context.read<HabitDatabase>().updateHabitName(
                          habit.id,
                          newHabitName,
                        );

                    Navigator.pop(context);

                    textController.clear();
                  },
                  child: const Text("Save"),
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);

                    textController.clear();
                  },
                  child: const Text("Cancel"),
                ),
              ],
            ));
  }

  void deleteHabitBox(Habit habit) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Are you sure you want to delete?"),
              actions: [
                MaterialButton(
                  onPressed: () {
                    context.read<HabitDatabase>().deleteHabit(
                          habit.id,
                        );

                    Navigator.pop(context);
                  },
                  child: const Text("Delete"),
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: const MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewHabit,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        child: const Icon(Icons.add),
      ),
      body: ListView(
        children: [
          _buildHeatMap(),
          _buildHabitList(),
        ],
      ),
    );
  }

  Widget _buildHeatMap() {
    final habitDatabase = context.watch<HabitDatabase>();

    List<Habit> currentHabits = habitDatabase.currentHabits;

    return FutureBuilder<DateTime?>(
      future: habitDatabase.getFirstLaunchDate(),
      builder: (context, snapshot) {
        // once the data is available -> build heatmap

        if (snapshot.hasData) {
          return MyHeatMap(
            startDate: snapshot.data!,
            datasets: prepHeatMapDataSet(currentHabits),
          );
        } else {
          return Container();
        }
      },
    );
  }

  Widget _buildHabitList() {
    // habit db
    final habitDatabase = context.watch<HabitDatabase>();

    // current habits
    List<Habit> currentHabits = habitDatabase.currentHabits;

    // return list of habits UI
    return ListView.builder(
        itemCount: currentHabits.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          // get each indivisual habit
          final habit = currentHabits[index];

          // check if the habit is completely today
          bool isCompletedToday = isHabitCompletedToday(habit.completedDays);
          return MyHabitTile(
            text: habit.name,
            isCompleted: isCompletedToday,
            onChanged: (value) => checkHabitOnOff(value, habit),
            editHabit: (context) => editHabitBox(habit),
            deleteHabit: (context) => deleteHabitBox(habit),
          );
        });
  }
}

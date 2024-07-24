import 'package:flutter/material.dart';
import 'package:gym_app/models/exercise.dart';
import 'package:provider/provider.dart';
import '../../providers/exercises_provider.dart';
import '../../models/set.dart';

class AddExerciseDialog extends StatefulWidget {
  const AddExerciseDialog({super.key});

  @override
  _AddExerciseDialogState createState() => _AddExerciseDialogState();
}

class _AddExerciseDialogState extends State<AddExerciseDialog> {
  Exercise? selectedExercise;
  List<Map<String, String>> sets = [];

  @override
  void initState() {
    super.initState();
    sets = [
      {'reps': '', 'weight': ''}
    ];
  }

  @override
  Widget build(BuildContext context) {
    List<Exercise> exerciseNames =
        Provider.of<ExercisesProvider>(context).exercises;

    return AlertDialog(
      title: const Text('Add Exercise'),
      content: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            DropdownButton<Exercise>(
              hint: const Text("Select Exercise"),
              value: selectedExercise,
              items: exerciseNames.map((Exercise exercise) {
                return DropdownMenuItem<Exercise>(
                  value: exercise,
                  child: Text(exercise.name),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedExercise = newValue;
                  sets = [
                    {'reps': '', 'weight': ''}
                  ]; // Reset sets when exercise is selected
                });
              },
            ),
            ...sets.map((set) {
              int index = sets.indexOf(set);
              return Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(labelText: 'Reps'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          sets[index]['reps'] = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                          labelText:
                              '${selectedExercise!.type == 'Bodyweight' ? 'Additional ' : ''}Weight'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          sets[index]['weight'] = value;
                        });
                      },
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  sets.add({'reps': '', 'weight': ''});
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Set'),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: const Text('Add Exercise'),
          onPressed: () {
            // Handle adding exercise logic here
            List<int> repsList =
                sets.map((set) => int.parse(set['reps']!)).toList();
            List<int>? weightList = sets
                .map((set) =>
                    set['weight']!.isNotEmpty ? int.parse(set['weight']!) : 0)
                .toList();

            Set newSet = Set(
              id: '',
              reps: repsList,
              weight: weightList,
              singleSetExercisesId: selectedExercise!.id,
            );
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

Future<void> showAddExerciseDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AddExerciseDialog();
    },
  );
}

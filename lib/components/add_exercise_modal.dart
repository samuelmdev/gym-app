import 'package:flutter/material.dart';
import 'package:gym_app/models/exercise.dart';
import 'package:provider/provider.dart';
import '../providers/exercises_provider.dart';
import '../models/set.dart';

class AddExerciseModal extends StatefulWidget {
  const AddExerciseModal({super.key, required this.workoutId});
  final String workoutId;

  @override
  _AddExerciseModalState createState() => _AddExerciseModalState();
}

class _AddExerciseModalState extends State<AddExerciseModal> {
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
    final exerciseProvider = Provider.of<ExercisesProvider>(context);
    final exercises = exerciseProvider.exercises;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const Text('Add Exercise', style: TextStyle(fontSize: 20)),
          const SizedBox(height: 20),
          DropdownButton<Exercise>(
            hint: const Text("Select Exercise"),
            value: selectedExercise,
            items: exercises!.map((Exercise exercise) {
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
          if (selectedExercise != null) ...[
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.yellow,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(8), // slightly rounded edges
                ),
              ),
              onPressed: () {
                setState(() {
                  sets.add({'reps': '', 'weight': ''});
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Set'),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.yellow,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(8), // slightly rounded edges
                  ),
                ),
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(8), // slightly rounded edges
                  ),
                ),
                child: const Text('Add Exercise'),
                onPressed: () {
                  // Handle adding exercise logic here
                  if (selectedExercise != null) {
                    List<int> repsList =
                        sets.map((set) => int.parse(set['reps']!)).toList();
                    List<int>? weightList = sets
                        .map((set) => set['weight']!.isNotEmpty
                            ? int.parse(set['weight']!)
                            : 0)
                        .toList();

                    Set newSet = Set(
                      id: widget.workoutId,
                      reps: repsList,
                      weight: weightList,
                      singleSetExercisesId: selectedExercise!.id,
                    );
                    Navigator.of(context).pop(newSet);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

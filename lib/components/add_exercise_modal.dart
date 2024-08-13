import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:gym_app/models/exercise.dart';
import 'package:provider/provider.dart';
import '../providers/exercises_provider.dart';
import '../models/set.dart';

class AddExerciseModal extends StatefulWidget {
  final String? workoutId;
  final Exercise? exercise; // Optional parameter for the exercise

  const AddExerciseModal({
    super.key,
    this.workoutId,
    this.exercise,
  });

  @override
  _AddExerciseModalState createState() => _AddExerciseModalState();
}

class _AddExerciseModalState extends State<AddExerciseModal> {
  List<Map<String, String>> sets = [];
  Exercise? selectedExercise;

  @override
  void initState() {
    super.initState();
    sets = [
      {'reps': '', 'weight': ''}
    ];
    selectedExercise = widget.exercise;
  }

  @override
  Widget build(BuildContext context) {
    final exerciseProvider = Provider.of<ExercisesProvider>(context);
    final exercises = exerciseProvider.exercises;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            selectedExercise != null ? selectedExercise!.name : 'Add Exercise',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 20),
          if (widget.exercise == null) // Show dropdown if no exercise is passed
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
                  ]; // Reset sets when a different exercise is selected
                });
              },
            ),
          if (selectedExercise != null) ...[
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: sets.length,
                itemBuilder: (context, index) {
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
                },
              ),
            ),
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
              onPressed: sets.length < 10
                  ? () {
                      setState(() {
                        sets.add({'reps': '', 'weight': ''});
                      });
                    }
                  : null,
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
                child: const Text('Add into workout'),
                onPressed: () {
                  if (selectedExercise != null) {
                    List<int> repsList =
                        sets.map((set) => int.parse(set['reps']!)).toList();
                    List<int>? weightList = sets
                        .map((set) => set['weight']!.isNotEmpty
                            ? int.parse(set['weight']!)
                            : 0)
                        .toList();

                    Set newSet = Set(
                      id: uuid(),
                      reps: repsList,
                      weight: weightList,
                      exercisesId: selectedExercise!.id,
                      workoutID: widget.workoutId,
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

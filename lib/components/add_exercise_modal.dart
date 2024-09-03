import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../models/set.dart';

class AddExerciseModal extends StatefulWidget {
  final String? workoutId;
  final Exercise? exercise;
  final Set? existingSet;
  final List<Exercise>? exercises; // Pass the list of exercises

  const AddExerciseModal({
    super.key,
    this.workoutId,
    this.exercise,
    this.existingSet,
    this.exercises, // Make it required
  });

  @override
  _AddExerciseModalState createState() => _AddExerciseModalState();
}

class _AddExerciseModalState extends State<AddExerciseModal> {
  late List<TextEditingController> _repsControllers;
  late List<TextEditingController> _weightControllers;
  Exercise? selectedExercise;

  @override
  void initState() {
    super.initState();
    selectedExercise = widget.exercise;

    if (widget.existingSet != null) {
      _repsControllers = widget.existingSet!.reps
          .map((rep) => TextEditingController(text: rep.toString()))
          .toList();
      _weightControllers = widget.existingSet!.weight != null
          ? widget.existingSet!.weight!
              .map((weight) => TextEditingController(text: weight.toString()))
              .toList()
          : [TextEditingController()];
    } else {
      _repsControllers = [TextEditingController()];
      _weightControllers = [TextEditingController()];
    }
  }

  @override
  void dispose() {
    for (var controller in _repsControllers) {
      controller.dispose();
    }
    for (var controller in _weightControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          if (widget.exercise == null)
            DropdownButton<Exercise>(
              hint: const Text("Select Exercise"),
              value: selectedExercise,
              items: widget.exercises
                  ?.map((exercise) => DropdownMenuItem<Exercise>(
                        value: exercise,
                        child: Text(exercise.name),
                      ))
                  .toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedExercise = newValue;
                  _repsControllers = [TextEditingController()];
                  _weightControllers = [TextEditingController()];
                });
              },
            ),
          if (selectedExercise != null) ...[
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _repsControllers.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _repsControllers[index],
                          decoration: const InputDecoration(labelText: 'Reps'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _weightControllers[index],
                          decoration: InputDecoration(
                              labelText:
                                  '${selectedExercise!.type == 'Bodyweight' ? 'Additional ' : ''}Weight'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      if (_repsControllers.length > 1) ...[
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _repsControllers.removeAt(index);
                              _weightControllers.removeAt(index);
                            });
                          },
                        ),
                      ],
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
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                if (_repsControllers.length < 10) {
                  setState(() {
                    _repsControllers.add(TextEditingController());
                    _weightControllers.add(TextEditingController());
                  });
                }
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
                    borderRadius: BorderRadius.circular(8),
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
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.yellow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Save'),
                onPressed: () {
                  if (selectedExercise != null) {
                    List<int> repsList = _repsControllers
                        .map((controller) => int.parse(controller.text))
                        .toList();
                    List<int>? weightList = _weightControllers
                        .map((controller) => controller.text.isNotEmpty
                            ? int.parse(controller.text)
                            : 0)
                        .toList();

                    Set newSet = Set(
                      id: widget.existingSet?.id ?? uuid(),
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

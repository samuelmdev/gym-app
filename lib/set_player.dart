// lib/screens/set_player.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym_app/models/completed_workout.dart';
import 'package:gym_app/models/exercise.dart';
import 'package:gym_app/models/set.dart';

import 'providers/completed_workout_provider.dart';

class SetPlayer extends StatefulWidget {
  final CompletedWorkout completedWorkout;
  final Exercise? exercise;
  final Set? sets;

  const SetPlayer(
      {super.key, required this.completedWorkout, this.exercise, this.sets});

  @override
  _SetPlayerState createState() => _SetPlayerState();
}

class _SetPlayerState extends State<SetPlayer> {
  int? selectedSetIndex = 0;
  late List<bool> completedSets;
  late Set? sets;
  late int length;

  @override
  void initState() {
    super.initState();
    completedSets = List.generate(widget.sets!.reps.length, (_) => false);
    sets = widget.sets;
    length = widget.sets!.reps.length;
  }

  Future<void> _showAddSetDialog(BuildContext context, String exerciseType,
      Function(int reps, int weight) onAddSet) async {
    final repsController = TextEditingController();
    final weightController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              'Add Set${exerciseType == 'Bodyweight' ? ' (Bodyweight)' : ''}'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: repsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Reps',
                  ),
                ),
                TextField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText:
                        ('${exerciseType == 'Bodyweight' ? 'Additional ' : ''}Weight (kg)'),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () {
                final int reps = int.parse(repsController.text);
                final int weight = int.parse(weightController.text);
                onAddSet(reps, weight);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _addOrEditSet({
    int? index,
    String? exerciseType,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        final isEditing = index != null;
        final repsController = TextEditingController(
          text: isEditing ? sets!.reps[index].toString() : '',
        );
        final weightController = TextEditingController(
          text: isEditing ? sets!.weight![index].toString() : '',
        );

        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isEditing ? 'Edit Set' : 'Add Set'),
              if (isEditing)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      sets!.reps.removeAt(index);
                      sets!.weight!.removeAt(index);
                    });
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.red,
                    backgroundColor: Colors.black,
                  ),
                  child: const Text('Delete Set'),
                ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: repsController,
                decoration: const InputDecoration(labelText: 'Reps'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: weightController,
                decoration: InputDecoration(
                    labelText:
                        '${exerciseType == 'Bodyweight' ? 'Additional ' : ''}Weight'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final reps = int.parse(repsController.text);
                final weight = int.parse(weightController.text);

                setState(() {
                  if (isEditing) {
                    sets!.reps[index] = reps;
                    sets!.weight![index] = weight;
                  } else {
                    sets!.reps.add(reps);
                    sets!.weight!.add(weight);
                  }
                });

                Navigator.of(context).pop();
              },
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  void markSetAsDone(int index) {
    setState(() {
      completedSets[index] = true;
      selectedSetIndex = index + 1;
    });
  }

  void _addSet(int reps, int weight) {
    setState(() {
      length = widget.sets!.reps.length + 1;
      widget.sets!.reps.add(reps);
      widget.sets!.weight!.add(weight);
      completedSets.add(false);
      length = widget.sets!.reps.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.exercise!.name),
            Text(widget.exercise!.type, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: sets!.reps.length,
              itemBuilder: (context, index) {
                Set set = sets!;
                bool isSelected = selectedSetIndex == index;

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          completedSets[index] ? Colors.green : Colors.black,
                      side: const BorderSide(color: Colors.yellow, width: 2.0),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8), // slightly rounded edges
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        selectedSetIndex = isSelected ? null : index;
                      });
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          'Set ${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        if (widget.exercise!.type == 'Bodyweight')
                          Text(
                            'Reps: ${set.reps[index]}${set.weight != null && set.weight!.isNotEmpty ? ' + Additional ${set.weight![index]} kg' : ''}',
                            style: const TextStyle(color: Colors.white),
                          )
                        else
                          Text(
                            'Reps: ${set.reps[index]} x ${set.weight![index]} kg',
                            style: const TextStyle(color: Colors.white),
                          ),
                        if (isSelected) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.yellow,
                                  side: const BorderSide(
                                      color: Colors.yellow, width: 2.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        8), // slightly rounded edges
                                  ),
                                ),
                                onPressed: () {
                                  // Handle Edit action
                                  _addOrEditSet(
                                      index: index,
                                      exerciseType: widget.exercise!.type);
                                },
                                child: const Text('Edit'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.yellow,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        8), // slightly rounded edges
                                  ),
                                ),
                                onPressed: () => markSetAsDone(index),
                                child: const Icon(Icons.check,
                                    color: Colors.black),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          //  if (selectedSetIndex! >= completedSets.length) ...[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    side: const BorderSide(color: Colors.yellow, width: 2.0),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8), // slightly rounded edges
                    ),
                  ),
                  onPressed: () {
                    // Handle Add set action
                    _showAddSetDialog(context, widget.exercise!.type, _addSet);
                  },
                  icon: const Icon(Icons.add_rounded, color: Colors.yellow),
                  label: const Text(
                    'Add set',
                    style: TextStyle(color: Colors.yellow),
                  ),
                ),
                const SizedBox(height: 8.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8), // slightly rounded edges
                    ),
                  ),
                  onPressed: () {
                    Provider.of<CompletedWorkoutProvider>(context,
                            listen: false)
                        .addSet(widget.exercise!, widget.sets!);
                    Provider.of<CompletedWorkoutProvider>(context,
                            listen: false)
                        .addExercise(widget.exercise!);
                    Navigator.pop(context);
                  },
                  child: const Text('Exercise ready',
                      style: TextStyle(color: Colors.black)),
                ),
                const SizedBox(height: 20.0),
              ],
            ),
          ),
        ],
        // ],
      ),
    );
  }
}

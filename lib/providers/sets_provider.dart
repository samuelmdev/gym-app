import 'package:flutter/material.dart';
import 'package:gym_app/models/set.dart';

import '../services/set_service.dart';

class SetsProvider with ChangeNotifier {
  List<Set> _sets = [];
  final Map<String, List<Set>> _exerciseSets = {};

  List<Set> get sets => _sets;

  // Getter to access sets for a specific exercise
  List<Set> getSetsForExercise(String exerciseId) {
    return _exerciseSets[exerciseId] ?? [];
  }

  Future<void> fetchSets(String workoutId) async {
    try {
      _sets = await SetService.listSingleSets(workoutId);
      notifyListeners();
    } catch (e) {
      print('Failed to fetch sets: $e');
    }
  }

  void addSet(Set set) {
    sets.add(set);
  }

  // Function to create a new set for a specific exercise
  void createSingleSet({
    required String exerciseId,
    required List<int> reps,
    required List<int>? weight,
    String? workoutId,
  }) {
    // Create a new Set object
    final newSet = Set(
      reps: reps,
      weight: weight,
      exercisesId: exerciseId,
      workoutID: workoutId,
    );

    // Add the new set to the list of sets for the specific exercise
    if (_exerciseSets[exerciseId] == null) {
      _exerciseSets[exerciseId] = [];
    }
    _exerciseSets[exerciseId]!.add(newSet);

    // Notify listeners that the sets have been updated
    notifyListeners();
  }

  // Function to delete a specific set by its ID
  void deleteSingleSet(String exerciseId, String setId) {
    // Find the set by ID and remove it from the list
    _exerciseSets[exerciseId]?.removeWhere((set) => set.id == setId);

    // Notify listeners that the sets have been updated
    notifyListeners();
  }

  // Function to update an existing set
  void updateSingleSet(String exerciseId, Set updatedSet) {
    // Find the index of the set to be updated
    int index = _exerciseSets[exerciseId]
            ?.indexWhere((set) => set.id == updatedSet.id) ??
        -1;

    if (index != -1) {
      // Replace the old set with the updated set
      _exerciseSets[exerciseId]![index] = updatedSet;

      // Notify listeners that the sets have been updated
      notifyListeners();
    }
  }

  // Function to clear all sets for an exercise
  void clearSetsForExercise(String exerciseId) {
    _exerciseSets[exerciseId]?.clear();

    // Notify listeners that the sets have been cleared
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:gym_app/models/set.dart';

import '../services/set_service.dart';

class SetsProvider with ChangeNotifier {
  List<Set> _sets = [];

  List<Set> get sets => _sets;

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
}

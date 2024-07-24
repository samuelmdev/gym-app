import 'package:flutter/material.dart';
import 'package:gym_app/models/set.dart';

class SetsProvider with ChangeNotifier {
  List<Set> _sets = [];

  List<Set> get exercises => _sets;

  void setSets(List<Set> sets) {
    _sets = sets;
    notifyListeners();
  }
}

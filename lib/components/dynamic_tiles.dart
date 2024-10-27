import 'package:flutter/material.dart';
import 'package:gym_app/components/weekly_calendar.dart';
import '../models/ready_workout.dart';
import 'weekly_bar_chart.dart';
import 'weekly_metrics.dart'; // Import WeeklyBarChart

class DynamicTiles extends StatefulWidget {
  final Map<DateTime, List<ReadyWorkout>> groupedWorkouts;
  final Map<String, dynamic> stats;
  final String userId;

  const DynamicTiles(
      {super.key,
      required this.groupedWorkouts,
      required this.stats,
      required this.userId});

  @override
  _DynamicTilesState createState() => _DynamicTilesState();
}

class _DynamicTilesState extends State<DynamicTiles> {
  int _selectedIndex = 0;

  final List<String> _titles = ['Schedule', 'Activity', 'Metrics'];
  final List<String> _routes = ['/schedule', '/progress', '/overview'];

  void _onSwipeLeft() {
    setState(() {
      _selectedIndex = (_selectedIndex + 1) % _titles.length;
    });
  }

  void _onSwipeRight() {
    setState(() {
      _selectedIndex = (_selectedIndex - 1 + _titles.length) % _titles.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        widget.groupedWorkouts.isEmpty &&
                widget.userId.isEmpty &&
                widget.stats.isEmpty
            ? Container(
                height: MediaQuery.of(context).size.height * 0.30,
                width: double.infinity,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: CircularProgressIndicator(),
                ))
            : GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  if (_selectedIndex == 0) {
                    Navigator.of(context)
                        .pushNamed('/schedule', arguments: widget.userId);
                  } else {
                    Navigator.of(context).pushNamed(_routes[_selectedIndex]);
                  }
                },
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity! < 0) {
                    _onSwipeLeft();
                  } else if (details.primaryVelocity! > 0) {
                    _onSwipeRight();
                  }
                },
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.30,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: _selectedIndex == 1
                        ? WeeklyBarChart(
                            groupedWorkouts: widget
                                .groupedWorkouts) // Use the WeeklyBarChart

                        : _selectedIndex == 2
                            ? WeeklyMetrics(
                                stats: widget
                                    .stats) // Show WeeklyMetrics for index 2
                            : WeeklyCalendar(userId: widget.userId),
                  ),
                ),
              ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _titles.asMap().entries.map((entry) {
            int index = entry.key;
            String label = entry.value;
            return _buildIconButton(index, _getIconForLabel(label), label);
          }).toList(),
        ),
      ],
    );
  }

  IconData _getIconForLabel(String label) {
    switch (label) {
      case 'Schedule':
        return Icons.schedule;
      case 'Activity':
        return Icons.assessment;
      case 'Metrics':
        return Icons.dashboard;
      default:
        return Icons.help;
    }
  }

  Widget _buildIconButton(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    return Expanded(
      child: TextButton(
        onPressed: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(
              isSelected ? Colors.yellow.withOpacity(0.1) : Colors.transparent),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.yellow : Colors.grey,
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  label,
                  style: const TextStyle(color: Colors.yellow),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

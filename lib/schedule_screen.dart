import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/workouts_provider.dart';

class ScheduleScreen extends StatefulWidget {
  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  String? selectedWorkout;
  DateTime? selectedDate;

  void _showScheduleModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Workout', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: selectedWorkout,
                isExpanded: true,
                items: Provider.of<WorkoutsProvider>(context)
                    .workouts!
                    .map<DropdownMenuItem<String>>((workout) {
                  return DropdownMenuItem<String>(
                    value: workout.id,
                    child: Text(workout.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedWorkout = value;
                  });
                },
                hint: const Text('Choose a workout'),
              ),
              const SizedBox(height: 20),
              const Text('Select Date', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      selectedDate = pickedDate;
                    });
                  }
                },
                child: Text(
                  selectedDate == null
                      ? 'Select Date'
                      : selectedDate!.toLocal().toString().split(' ')[0],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Handle scheduling logic here
                    Navigator.pop(context);
                  },
                  child: const Text('Schedule'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const passedWorkouts = 5; // Placeholder value, replace with real data
    const scheduledWorkouts = 3; // Placeholder value, replace with real data

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule', style: TextStyle(fontSize: 20)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.25,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  'Placeholder for schedule content',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('X Passed workouts'),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: const Text(
                        '$passedWorkouts',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Y Scheduled workouts'),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.lightBlue,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: const Text(
                        '$scheduledWorkouts',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(8), // slightly rounded edges
                ),
              ),
              onPressed: () {
                _showScheduleModal(context);
              },
              child: const Text('Schedule Workout'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

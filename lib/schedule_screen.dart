import 'package:flutter/material.dart';
import 'package:gym_app/models/ready_workout.dart';
import 'package:gym_app/models/scheduled_workout.dart';
import 'package:gym_app/providers/ready_workout_provider.dart';
import 'package:provider/provider.dart';
import './services/schedule_workout_service.dart';
import 'providers/workouts_provider.dart';
import 'providers/scheduled_workout_provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:gym_app/models/date.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  List<ReadyWorkout> passedWorkouts =
      []; // Replace with your passed workouts list
  List<ScheduledWorkout> scheduledWorkouts =
      []; // Replace with your scheduled workouts list

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    passedWorkouts = Provider.of<ReadyWorkoutProvider>(context).readyWorkouts;
    scheduledWorkouts =
        Provider.of<ScheduledWorkoutsProvider>(context).scheduledWorkouts;
  }

  String? selectedWorkout;
  DateTime? selectedDate;
  late String userID = ModalRoute.of(context)!.settings.arguments as String;
  void _showScheduleModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
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
                    items: Provider.of<WorkoutsProvider>(context, listen: false)
                        .workouts!
                        .map<DropdownMenuItem<String>>((workout) {
                      return DropdownMenuItem<String>(
                        value: workout.id,
                        child: Text(workout.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setModalState(() {
                        selectedWorkout = value!;
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
                        setModalState(() {
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        if (selectedWorkout == null || selectedDate == null) {
                          // If the user hasn't selected a workout or a date
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Please select both workout and date'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        try {
                          await ScheduledWorkoutService.createScheduledWorkout(
                            date: selectedDate!,
                            userID:
                                userID, // Make sure this is initialized correctly
                            workoutID: selectedWorkout!,
                          );

                          // Notify the user that the workout has been scheduled successfully
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Workout scheduled successfully!'),
                              backgroundColor: Colors.lightBlue,
                            ),
                          );

                          // Fetch the updated list of scheduled workouts after scheduling
                          await Provider.of<ScheduledWorkoutsProvider>(
                            context,
                            listen: false,
                          ).fetchScheduledWorkouts(userID);

                          Navigator.pop(
                              context); // Close the modal after success
                        } catch (e) {
                          print('Error scheduling workout: $e');
                        }
                      },
                      child: const Text('Schedule'),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEventsMarker(DateTime date) {
    bool hasPassedWorkouts = Provider.of<ReadyWorkoutProvider>(context)
        .getReadyWorkoutsByDate(date)
        .isNotEmpty; // Adjust your condition
    bool hasScheduledWorkouts = Provider.of<ScheduledWorkoutsProvider>(context)
        .getScheduledWorkoutsForDate(date)
        .isNotEmpty;

    List<Widget> markers = [];
    if (hasPassedWorkouts) {
      markers.add(Container(
        width: 10.0,
        height: 12.0,
        margin: const EdgeInsets.symmetric(horizontal: 1.5),
        decoration: const BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.green,
        ),
      ));
    }
    if (hasScheduledWorkouts) {
      markers.add(Container(
        width: 10.0,
        height: 12.0,
        margin: const EdgeInsets.symmetric(horizontal: 1.5),
        decoration: const BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.lightBlue,
        ),
      ));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: markers,
    );
  }

  @override
  Widget build(BuildContext context) {
    var passedWorkouts = Provider.of<ReadyWorkoutProvider>(context)
        .getReadyWorkoutsByDate(_selectedDay!);
    var scheduledWorkouts = Provider.of<ScheduledWorkoutsProvider>(context)
        .getScheduledWorkoutsForDate(_selectedDay!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule', style: TextStyle(fontSize: 20)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.25,
              child: TableCalendar(
                firstDay: DateTime.utc(2022, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: CalendarFormat.week,
                startingDayOfWeek: StartingDayOfWeek.monday,
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    color: Colors.white, // Set the text color to white
                    fontSize: 14, // Increase the font size
                  ),
                  weekendStyle: TextStyle(
                    color:
                        Colors.white, // Ensure weekend days are white as well
                    fontSize: 14, // Increase the font size for weekends too
                  ),
                ),
                availableCalendarFormats: const {
                  CalendarFormat.week: 'Week'
                }, // Lock to week view
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay =
                        focusedDay; // update `_focusedDay` here as well
                  });
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    return _buildEventsMarker(date);
                  },
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.yellow,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  todayTextStyle: const TextStyle(
                      color: Colors.black, fontSize: 20), // Updated font size
                  selectedDecoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.yellow, width: 2),
                  ),
                  selectedTextStyle: const TextStyle(
                      color: Colors.yellow, fontSize: 16), // Updated font size
                  markersMaxCount: 2,
                  weekendDecoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  defaultDecoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  outsideDecoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  disabledDecoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  // Adjusting the font size for day text
                  defaultTextStyle:
                      const TextStyle(fontSize: 16), // Set default text size
                  weekendTextStyle:
                      const TextStyle(fontSize: 16), // Set weekend text size
                ),
              ),
            ),
            // Expanded view to show more details about selected day
            Container(
              padding: const EdgeInsets.all(10.0),
              height: MediaQuery.of(context).size.height * 0.40,
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    CustomDateUtils.formatDate(_selectedDay!),
                    style: const TextStyle(
                        fontSize: 16.0, color: Colors.white), // Updated color
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${passedWorkouts.length} Passed Workouts',
                    style: const TextStyle(
                        fontSize: 18.0,
                        color: Colors.green), // Passed workouts text
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${scheduledWorkouts.length} Scheduled Workouts',
                    style: const TextStyle(
                        fontSize: 18.0,
                        color: Colors.lightBlue), // Scheduled workouts text
                  ),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 18),
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
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

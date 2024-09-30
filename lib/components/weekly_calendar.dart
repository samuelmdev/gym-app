import 'package:flutter/material.dart';
import 'package:gym_app/models/ready_workout.dart';
import 'package:gym_app/models/scheduled_workout.dart';
import 'package:gym_app/providers/ready_workout_provider.dart';
import 'package:provider/provider.dart';
import '../providers/scheduled_workout_provider.dart';
import 'package:table_calendar/table_calendar.dart';

class WeeklyCalendar extends StatefulWidget {
  WeeklyCalendar({super.key, required this.userId});
  final String userId;

  @override
  _WeeklyCalendarState createState() => _WeeklyCalendarState();
}

class _WeeklyCalendarState extends State<WeeklyCalendar> {
  final DateTime _focusedDay = DateTime.now();
  final DateTime _selectedDay = DateTime.now();
  List<ReadyWorkout> passedWorkouts = [];
  List<ScheduledWorkout> scheduledWorkouts = [];
  var passedWorkoutsCount = 0;
  var scheduledWorkoutsCount = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    passedWorkoutsCount = Provider.of<ReadyWorkoutProvider>(context)
        .getReadyWorkoutsByDate(_selectedDay)
        .length;
    scheduledWorkoutsCount = Provider.of<ScheduledWorkoutsProvider>(context)
        .getScheduledWorkoutsForDate(_selectedDay)
        .length;

    passedWorkouts = Provider.of<ReadyWorkoutProvider>(context).readyWorkouts;
    scheduledWorkouts =
        Provider.of<ScheduledWorkoutsProvider>(context).scheduledWorkouts;
  }

  String? selectedWorkout;
  DateTime? selectedDate;

  Widget _buildEventsMarker(DateTime date) {
    bool hasPassedWorkouts = Provider.of<ReadyWorkoutProvider>(context)
        .getReadyWorkoutsByDate(date)
        .isNotEmpty;
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
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Column(
        children: [
          _buildCalendarTile(),
        ],
      ),
    );
  }

  Widget _buildCalendarTile() {
    return Container(
      // height: MediaQuery.of(context).size.height * 0.30,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2022, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.week,
            startingDayOfWeek: StartingDayOfWeek.monday, // Start week on Monday
            pageAnimationEnabled: false,
            pageJumpingEnabled: false,
            daysOfWeekVisible: true,
            shouldFillViewport: false,
            headerVisible: false,
            availableGestures: AvailableGestures.none,
            availableCalendarFormats: const {CalendarFormat.week: 'Week'},
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: Colors.white, // Set the text color to white
                fontSize: 14, // Increase the font size
              ),
              weekendStyle: TextStyle(
                color: Colors.white, // Ensure weekend days are white as well
                fontSize: 14, // Increase the font size for weekends too
              ),
            ),
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              Navigator.of(context)
                  .pushNamed('/schedule', arguments: widget.userId);
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
              todayTextStyle:
                  const TextStyle(color: Colors.black, fontSize: 16),
              selectedDecoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.yellow, width: 2),
              ),
              selectedTextStyle:
                  const TextStyle(color: Colors.yellow, fontSize: 16),
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
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '$passedWorkoutsCount Passed Workouts for this week',
            style: const TextStyle(fontSize: 16.0, color: Colors.green),
          ),
          const SizedBox(height: 5),
          Text(
            '$scheduledWorkoutsCount Scheduled Workouts for this week',
            style: const TextStyle(fontSize: 16.0, color: Colors.lightBlue),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class EventCalendarScreen extends StatefulWidget {
  const EventCalendarScreen({super.key});

  @override
  State<EventCalendarScreen> createState() => _EventCalendarScreenState();
}

class _EventCalendarScreenState extends State<EventCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Real Sri Lanka events in 2026
  final Map<DateTime, List<String>> _events = {
    DateTime(2026, 2, 1): ["Navam Full Moon Poya & Perahera"],
    DateTime(2026, 2, 4): ["Sri Lanka Independence Day"],
    DateTime(2026, 2, 7): ["ICC Men's T20 World Cup Begins"],
    DateTime(2026, 2, 15): ["Maha Shivaratri"],
    DateTime(2026, 1, 22): ["Galle Literary Festival Begins"],
    DateTime(2026, 1, 23): ["Galle Literary Festival"],
    DateTime(2026, 1, 24): ["Galle Literary Festival"],
    DateTime(2026, 1, 25): ["Galle Literary Festival Ends"],
    DateTime(2026, 4, 13): ["Sinhala & Tamil New Year Eve"],
    DateTime(2026, 4, 14): ["Sinhala & Tamil New Year"],
    DateTime(2026, 5, 1): ["Vesak Poya"],
    DateTime(2026, 6, 18): ["Sri Lanka Expo 2026"],
    DateTime(2026, 7, 8): ["Lanka Premier League Cricket Begins"],
    DateTime(2026, 8, 18): ["Kandy Esala Perahera Begins"],
    DateTime(2026, 8, 28): ["Kandy Esala Perahera Ends"],
    DateTime(2026, 3, 8): ["ICC Men's T20 World Cup Final"],
  };

  // Get events for a selected day
  List<String> _getEventsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _events[key] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    // Prepare upcoming events
    List<MapEntry<DateTime, List<String>>> upcomingEvents = _events.entries
        .where((e) {
      final today = DateTime.now();
      final eventDate = DateTime(e.key.year, e.key.month, e.key.day);
      return eventDate.isAfter(today) ||
          eventDate.isAtSameMomentAs(DateTime(today.year, today.month, today.day));
    })
        .toList();

    upcomingEvents.sort((a, b) => a.key.compareTo(b.key));
    upcomingEvents = upcomingEvents.take(5).toList();

    final upcomingEventWidgets = upcomingEvents.map((entry) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          leading: const Icon(Icons.event_note, color: Colors.orange),
          title: Text(entry.value.join(", ")),
          subtitle: Text(
            "${entry.key.year}-${entry.key.month.toString().padLeft(2, '0')}-${entry.key.day.toString().padLeft(2, '0')}",
          ),
        ),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sri Lanka Event Calendar"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2026, 1, 1),
            lastDay: DateTime(2026, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: _getEventsForDay,
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Events for selected day
          if (_selectedDay != null && _getEventsForDay(_selectedDay!).isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Events on Selected Day",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ..._getEventsForDay(_selectedDay!).map(
                      (event) => ListTile(
                    leading: const Icon(Icons.event_available, color: Colors.deepPurple),
                    title: Text(event),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 10),

          // Upcoming events
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Upcoming Events",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView(
              children: upcomingEventWidgets,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

// ─────────────────────────────────────────────
//  Design tokens
// ─────────────────────────────────────────────
const _bg         = Color(0xFF0D0F14);
const _surface    = Color(0xFF161A23);
const _card       = Color(0xFF1E2330);
const _accent     = Color(0xFFE8C97A);   // warm gold
const _accentSoft = Color(0x33E8C97A);
const _accentGlow = Color(0x1AE8C97A);
const _textPri    = Color(0xFFF2F2F7);
const _textSec    = Color(0xFF8A8FA8);
const _divider    = Color(0xFF252A38);
const _red        = Color(0xFFFF6B6B);
const _green      = Color(0xFF50E3A4);

class EventCalendarScreenW extends StatefulWidget {
  const EventCalendarScreenW({super.key});

  @override
  State<EventCalendarScreenW> createState() => _EventCalendarScreenState();
}

class _EventCalendarScreenState extends State<EventCalendarScreenW>
    with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;

  DateTime _focusedDay  = DateTime.now();
  DateTime? _selectedDay;

  Map<DateTime, List<Map<String, dynamic>>> _events = {};
  bool _isLoading = true;

  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();

    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    fetchEvents();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  DateTime _normalizeDate(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<void> fetchEvents() async {
    try {
      final response = await supabase
          .from('events')
          .select()
          .order('event_date', ascending: true);

      final Map<DateTime, List<Map<String, dynamic>>> loaded = {};
      for (final item in response) {
        final key = _normalizeDate(DateTime.parse(item['event_date']));
        loaded.putIfAbsent(key, () => []).add(item);
      }

      setState(() {
        _events    = loaded;
        _isLoading = false;
      });
      _fadeCtrl.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to load events: $e'),
          backgroundColor: _red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    }
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) =>
      _events[_normalizeDate(day)] ?? [];

  List<Map<String, dynamic>> _getUpcoming() {
    final today = _normalizeDate(DateTime.now());
    final upcoming = _events.entries
        .where((e) => !e.key.isBefore(today))
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return [
      for (final entry in upcoming)
        for (final event in entry.value)
          {...event, '_date': entry.key},
    ].take(8).toList();
  }

  // ─── build ────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final selectedEvents = _getEventsForDay(_selectedDay ?? DateTime.now());
    final upcoming       = _getUpcoming();

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: _bg,
        colorScheme: const ColorScheme.dark(primary: _accent),
      ),
      child: Scaffold(
        backgroundColor: _bg,
        body: _isLoading
            ? const _LoadingView()
            : FadeTransition(
          opacity: _fadeAnim,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildHeader(),
              _buildCalendar(),
              if (upcoming.isNotEmpty) ...[
                _sectionLabel('Upcoming Events', Icons.auto_awesome),
                _buildUpcomingStrip(upcoming),
              ],
              _sectionLabel(
                DateFormat('EEEE, MMMM d').format(_selectedDay!),
                Icons.event_available_rounded,
              ),
              selectedEvents.isEmpty
                  ? _buildEmpty()
                  : _buildEventList(selectedEvents),
              const SliverToBoxAdapter(child: SizedBox(height: 60)),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header ──────────────────────────────
  Widget _buildHeader() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 90,
      backgroundColor: _bg,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 24, bottom: 14),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SRI LANKA',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 10,
                letterSpacing: 4,
                color: _accent,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Text(
              'Events',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _textPri,
                height: 1.1,
              ),
            ),
          ],
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF111319), _bg],
            ),
          ),
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 48, right: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _accentSoft,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _accent.withOpacity(0.4)),
                ),
                child: Text(
                  DateFormat('MMM yyyy').format(DateTime.now()).toUpperCase(),
                  style: const TextStyle(
                    color: _accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Calendar ─────────────────────────────
  Widget _buildCalendar() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: _divider),
          boxShadow: const [
            BoxShadow(color: Color(0x40000000), blurRadius: 24, offset: Offset(0, 8)),
          ],
        ),
        child: TableCalendar(
          firstDay: DateTime(2025, 1, 1),
          lastDay: DateTime(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
          onDaySelected: (sel, foc) {
            setState(() {
              _selectedDay = sel;
              _focusedDay  = foc;
            });
          },
          eventLoader: _getEventsForDay,
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            leftChevronIcon:  Icon(Icons.chevron_left,  color: _textSec),
            rightChevronIcon: Icon(Icons.chevron_right, color: _textSec),
            titleTextStyle: TextStyle(
              fontFamily: 'Georgia',
              color: _textPri,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            headerPadding: EdgeInsets.symmetric(vertical: 12),
          ),
          daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle: TextStyle(color: _textSec, fontSize: 12, fontWeight: FontWeight.w600),
            weekendStyle: TextStyle(color: _accent,  fontSize: 12, fontWeight: FontWeight.w600),
          ),
          calendarStyle: CalendarStyle(
            defaultTextStyle:   const TextStyle(color: _textPri, fontSize: 13),
            weekendTextStyle:   const TextStyle(color: _textPri, fontSize: 13),
            outsideTextStyle:   TextStyle(color: _textSec.withOpacity(0.3), fontSize: 13),
            todayDecoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _accent, width: 1.5),
            ),
            todayTextStyle: const TextStyle(color: _accent, fontWeight: FontWeight.bold, fontSize: 13),
            selectedDecoration: const BoxDecoration(color: _accent, shape: BoxShape.circle),
            selectedTextStyle: const TextStyle(color: _bg, fontWeight: FontWeight.bold, fontSize: 13),
            markerDecoration: const BoxDecoration(color: _green, shape: BoxShape.circle),
            markerSize: 5,
            markersMaxCount: 3,
            outsideDaysVisible: false,
            rowDecoration: const BoxDecoration(color: Colors.transparent),
            tablePadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isEmpty) return const SizedBox.shrink();
              return Positioned(
                bottom: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 5, height: 5,
                      decoration: BoxDecoration(
                        color: events.length > 1 ? _accent : _green,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ─── Section label ────────────────────────
  Widget _sectionLabel(String text, IconData icon) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _accentSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: _accent, size: 14),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: _textPri,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Upcoming strip ───────────────────────
  Widget _buildUpcomingStrip(List<Map<String, dynamic>> events) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 110,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          physics: const BouncingScrollPhysics(),
          itemCount: events.length,
          itemBuilder: (ctx, i) {
            final e    = events[i];
            final date = e['_date'] as DateTime;
            final isToday = isSameDay(date, DateTime.now());

            return GestureDetector(
              onTap: () => setState(() {
                _selectedDay = date;
                _focusedDay  = date;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 145,
                margin: const EdgeInsets.only(right: 12, bottom: 4, top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isToday ? _accentSoft : _card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isToday ? _accent : _divider,
                    width: isToday ? 1.5 : 1,
                  ),
                  boxShadow: isToday
                      ? [const BoxShadow(color: _accentGlow, blurRadius: 16, offset: Offset(0, 4))]
                      : [],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: isToday ? _accent : _surface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        DateFormat('dd MMM').format(date).toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: isToday ? _bg : _accent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      e['title'] ?? 'Event',
                      style: const TextStyle(
                        color: _textPri,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── Empty state ──────────────────────────
  Widget _buildEmpty() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: _card,
                shape: BoxShape.circle,
                border: Border.all(color: _divider),
              ),
              child: const Icon(Icons.calendar_month_outlined, color: _textSec, size: 30),
            ),
            const SizedBox(height: 16),
            const Text('No events today', style: TextStyle(color: _textSec, fontSize: 14)),
            const SizedBox(height: 4),
            const Text(
              'Select another day or check upcoming',
              style: TextStyle(color: Color(0xFF555A70), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Event list ───────────────────────────
  Widget _buildEventList(List<Map<String, dynamic>> events) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (ctx, i) => _EventCard(event: events[i]),
        childCount: events.length,
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Event card widget
// ─────────────────────────────────────────────
class _EventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _divider),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left accent strip
              Container(
                width: 4,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_accent, Color(0xFFD4A832)],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title row
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              event['title'] ?? '',
                              style: const TextStyle(
                                color: _textPri,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _accentGlow,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: _accent.withOpacity(0.2)),
                            ),
                            child: const Text(
                              'EVENT',
                              style: TextStyle(
                                color: _accent,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (event['location'] != null &&
                          event['location'].toString().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: _red.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.place_rounded, color: _red, size: 11),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                event['location'],
                                style: const TextStyle(color: _textSec, fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],

                      if (event['description'] != null &&
                          event['description'].toString().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          event['description'],
                          style: TextStyle(
                            color: _textSec.withOpacity(0.85),
                            fontSize: 13,
                            height: 1.45,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Loading view
// ─────────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              color: _accent,
              strokeWidth: 2.5,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Loading events…',
            style: TextStyle(color: _textSec, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../widgets/glowing_action_button.dart';
import 'note_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  bool _showCalendar = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Планировщик задач',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      GlowingActionButton(
                        icon: _showCalendar ? Icons.list : Icons.calendar_today,
                        color: Colors.blue,
                        onPressed: () {
                          setState(() {
                            _showCalendar = !_showCalendar;
                          });
                        },
                        size: 40,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_showCalendar)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2B2E),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(4, 4),
                    ),
                  ],
                ),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  calendarStyle: CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            Expanded(
              child: Consumer<NotesProvider>(
                builder: (context, notesProvider, child) {
                  // Если активен режим календаря, показываем только заметки для выбранного дня
                  final notes = _showCalendar 
                    ? notesProvider.getNotesForDate(_selectedDay)
                    : notesProvider.notes;

                  if (notes.isEmpty) {
                    return Center(
                      child: Text(
                        'Нет задач',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildTaskCard(notes[index]),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: GlowingActionButton(
        icon: Icons.add,
        color: Colors.blue,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteScreen(selectedDate: _selectedDay),
            ),
          );
        },
        size: 60,
      ),
    );
  }

  Widget _buildTaskCard(Note note) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2B2E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(4, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NoteScreen(note: note),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 110,
                decoration: BoxDecoration(
                  color: note.color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: note.color.withOpacity(0.2),
                            radius: 14,
                            child: Text(
                              note.title.isNotEmpty ? note.title[0] : "N",
                              style: TextStyle(
                                color: note.color, 
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              note.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (note.date != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: note.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${note.date!.day}.${note.date!.month}',
                                style: TextStyle(
                                  color: note.color,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        note.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: note.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Задача',
                              style: TextStyle(
                                color: note.color,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.comment_outlined,
                                color: Colors.grey[500],
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '0',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.attach_file,
                                color: Colors.grey[500],
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '0',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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

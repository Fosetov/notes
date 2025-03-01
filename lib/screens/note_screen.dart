import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../widgets/glowing_action_button.dart';

class NoteScreen extends StatefulWidget {
  final Note? note;
  final DateTime? selectedDate;

  const NoteScreen({super.key, this.note, this.selectedDate});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  DateTime? _selectedDate;
  bool _isEdited = false;
  Color _selectedColor = Colors.blue;

  final List<Color> _colors = [
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.pink,
    Colors.orange,
    Colors.teal,
    Colors.indigo,
    Colors.red,
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _selectedDate = widget.note?.date ?? widget.selectedDate;
    _selectedColor = widget.note?.color ?? Colors.blue;

    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (!_isEdited &&
        (_titleController.text.isNotEmpty || _contentController.text.isNotEmpty)) {
      setState(() {
        _isEdited = true;
      });
    }
  }

  void _saveNote() {
    final note = Note(
      id: widget.note?.id,
      title: _titleController.text,
      content: _contentController.text,
      date: _selectedDate,
      color: _selectedColor,
    );

    if (widget.note == null) {
      Provider.of<NotesProvider>(context, listen: false).addNote(note);
    } else {
      Provider.of<NotesProvider>(context, listen: false).updateNote(note);
    }

    Navigator.pop(context);
  }

  void _deleteNote() {
    if (widget.note != null) {
      Provider.of<NotesProvider>(context, listen: false).deleteNote(widget.note!.id!);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (widget.note != null)
            GlowingActionButton(
              icon: Icons.delete,
              color: Colors.red,
              onPressed: _deleteNote,
              size: 40,
            ),
          const SizedBox(width: 8),
          GlowingActionButton(
            icon: _selectedDate != null ? Icons.event : Icons.event_outlined,
            color: Colors.purple,
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (date != null) {
                setState(() {
                  _selectedDate = date;
                  _isEdited = true;
                });
              }
            },
            size: 40,
          ),
          const SizedBox(width: 8),
          PopupMenuButton<Color>(
            icon: Icon(Icons.palette, color: _selectedColor),
            itemBuilder: (context) => _colors
                .map(
                  (color) => PopupMenuItem(
                    value: color,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                )
                .toList(),
            onSelected: (color) {
              setState(() {
                _selectedColor = color;
                _isEdited = true;
              });
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_selectedDate != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _selectedColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}',
                  style: TextStyle(
                    color: _selectedColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Заголовок',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  hintText: 'Содержание заметки...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(fontSize: 16),
                maxLines: null,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: GlowingActionButton(
        icon: Icons.save,
        color: Colors.green,
        onPressed: _saveNote,
        size: 60,
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:developer' as developer;
import '../models/note.dart';

class NotesProvider with ChangeNotifier {
  List<Note> _notes = [];
  Database? _database;

  List<Note> get notes => _notes;

  Future<void> initDatabase() async {
    if (_database != null) return;

    developer.log('Инициализация базы данных');
    
    final dbPath = join(await getDatabasesPath(), 'notes.db');
    
    // Удаляем базу данных только при изменении схемы
    // await deleteDatabase(dbPath);

    _database = await openDatabase(
      dbPath,
      onCreate: (db, version) {
        developer.log('Создание таблицы notes');
        return db.execute(
          'CREATE TABLE notes(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, content TEXT, date TEXT, createdAt TEXT, color INTEGER)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        developer.log('Обновление базы данных с версии $oldVersion до $newVersion');
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE notes ADD COLUMN color INTEGER DEFAULT ${Colors.blue.value}');
        }
      },
      version: 2,
    );
    
    await loadNotes();
  }

  Future<void> loadNotes() async {
    if (_database == null) await initDatabase();
    
    try {
      final List<Map<String, dynamic>> maps = await _database!.query('notes');
      developer.log('Загружено заметок: ${maps.length}');
      
      _notes = List.generate(maps.length, (i) => Note.fromMap(maps[i]));
      notifyListeners();
    } catch (e) {
      developer.log('Ошибка загрузки заметок: $e');
    }
  }

  Future<void> addNote(Note note) async {
    if (_database == null) await initDatabase();
    
    try {
      final id = await _database!.insert('notes', note.toMap());
      developer.log('Добавлена заметка с id: $id');
      
      _notes.add(Note.fromMap({...note.toMap(), 'id': id}));
      notifyListeners();
    } catch (e) {
      developer.log('Ошибка добавления заметки: $e');
    }
  }

  Future<void> updateNote(Note note) async {
    if (_database == null) await initDatabase();
    
    try {
      await _database!.update(
        'notes',
        note.toMap(),
        where: 'id = ?',
        whereArgs: [note.id],
      );
      
      developer.log('Обновлена заметка с id: ${note.id}');
      
      final index = _notes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        _notes[index] = note;
        notifyListeners();
      }
    } catch (e) {
      developer.log('Ошибка обновления заметки: $e');
    }
  }

  Future<void> deleteNote(int id) async {
    if (_database == null) await initDatabase();
    
    try {
      await _database!.delete(
        'notes',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      developer.log('Удалена заметка с id: $id');
      
      _notes.removeWhere((note) => note.id == id);
      notifyListeners();
    } catch (e) {
      developer.log('Ошибка удаления заметки: $e');
    }
  }

  List<Note> getNotesForDate(DateTime date) {
    return _notes.where((note) {
      if (note.date == null) return false;
      return note.date!.year == date.year &&
          note.date!.month == date.month &&
          note.date!.day == date.day;
    }).toList();
  }
}

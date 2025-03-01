import 'package:flutter/material.dart';

class Note {
  final int? id;
  final String title;
  final String content;
  final DateTime? date;
  final DateTime createdAt;
  final Color color;

  Note({
    this.id,
    required this.title,
    required this.content,
    this.date,
    DateTime? createdAt,
    Color? color,
  }) : createdAt = createdAt ?? DateTime.now(),
       color = color ?? Colors.blue;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'color': color.value,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      date: map['date'] != null ? DateTime.parse(map['date']) : null,
      createdAt: DateTime.parse(map['createdAt']),
      color: Color(map['color'] ?? Colors.blue.value),
    );
  }
}

// models/tasks.dart
import 'package:flutter/material.dart';

class TaskItem {
  final String id;
  final String title;
  final int progress;
  final Color color;
  final String date; // format: DD MMMM YYYY (e.g., 02 Desember 2024)
  final String time; // format: HH:MM - HH:MM

  const TaskItem({
    required this.id,
    required this.title,
    required this.progress,
    required this.color,
    required this.date,
    required this.time,
  });
}

// Sumber data bersama untuk Home dan Kalender
List<TaskItem> sharedTasks = [
  TaskItem(
    id: 'task-1',
    title: 'Pengolahan Tanah',
    progress: 83,
    color: Color(0xFF7B5B18),
    date: '02 Desember 2025',
    time: '08:00 - 11:00',
  ),
  TaskItem(
    id: 'task-2',
    title: 'Penanaman Bibit',
    progress: 72,
    color: Color(0xFF617F59),
    date: '10 Desember 2025',
    time: '07:00 - 12:00',
  ),
  TaskItem(
    id: 'task-3',
    title: 'Pestisida',
    progress: 49,
    color: Color(0xFF7F7E79),
    date: '28 Desember 2025',
    time: '07:00 - 10:00',
  ),
  TaskItem(
    id: 'task-4',
    title: 'Pemupukan',
    progress: 58,
    color: Color(0xFFD9C36A),
    date: '01 Januari 2026',
    time: '07:00 - 12:00',
  ),
];

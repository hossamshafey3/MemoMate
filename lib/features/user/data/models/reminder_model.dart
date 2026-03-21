// ─────────────────────────────────────────────
//  reminder_model.dart  –  Memomate
// ─────────────────────────────────────────────

import 'package:equatable/equatable.dart';

class ReminderModel extends Equatable {
  final String id;
  final String name;
  final String dose;
  final String date;
  final String time;
  final int times;

  const ReminderModel({
    required this.id,
    required this.name,
    required this.dose,
    required this.date,
    required this.time,
    required this.times,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      dose: json['dose']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      times: json['times'] is int ? json['times'] as int : int.tryParse(json['times'].toString()) ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dose': dose,
      'date': date,
      'time': time,
      'times': times,
    };
  }

  @override
  List<Object?> get props => [id, name, dose, date, time, times];
}

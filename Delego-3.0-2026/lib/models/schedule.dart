// Path: lib/models/schedule.dart

// --- UPDATED MODEL FOR SCHEDULE EVENT ---

class Schedule {
  final String id;
  // <--- ADDED THE MISSING 'day' PROPERTY HERE --->
  final String day;
  final String name;
  final String location;
  final String time;
  final String description;
  final String imageUrl;

  const Schedule({
    required this.id,
    // <--- REQUIRED IN CONSTRUCTOR --->
    required this.day,
    required this.name,
    required this.location,
    required this.time,
    required this.description,
    required this.imageUrl,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] as String,
      day: json['day'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      time: json['time'] as String,
      description: json['description'] as String,
      imageUrl: json['image'] as String,
    );
  }
}

// --- MODEL FOR CONFERENCE DAY METADATA (remains the same) ---

class ConferenceDay {
  final String dayKey;
  final String displayDate;

  ConferenceDay({
    required this.dayKey,
    required this.displayDate,
  });

  factory ConferenceDay.fromJson(Map<String, dynamic> json) {
    return ConferenceDay(
      dayKey: json['day_key'] as String,
      displayDate: json['display_date'] as String,
    );
  }
}
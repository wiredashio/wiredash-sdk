import 'package:flutter/foundation.dart';

@immutable
class Label {
  const Label({
    required this.id,
    required this.title,
    this.description,
  });

  final String id;
  final String title;
  final String? description;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Label &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description);

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ description.hashCode;

  @override
  String toString() {
    return 'Label{'
        'id: $id, '
        'title: $title, '
        'description: $description'
        '}';
  }

  Label copyWith({
    String? id,
    String? title,
    String? description,
  }) {
    return Label(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }
}

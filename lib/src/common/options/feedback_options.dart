class WiredashFeedbackOptions {
  final List<Label>? labels;
  final bool askForUserEmail;
  // TODO move pen color in here

  const WiredashFeedbackOptions({
    this.labels,
    this.askForUserEmail = true,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WiredashFeedbackOptions &&
          runtimeType == other.runtimeType &&
          labels == other.labels &&
          askForUserEmail == other.askForUserEmail);

  @override
  int get hashCode => labels.hashCode ^ askForUserEmail.hashCode;

  @override
  String toString() {
    return 'WiredashFeedbackOptions{'
        'labels: $labels, '
        'askForUserEmail: $askForUserEmail'
        '}';
  }
}

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

class Classroom {
  final String id;
  final String name;
  final List<String> users;

  Classroom({required this.id, required this.name, this.users = const []});

  factory Classroom.fromMap(Map<String, dynamic> data) {
    return Classroom(
      id: data['id'],
      name: data['name'],
      users: List<String>.from(data['users'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'users': users};
  }
}
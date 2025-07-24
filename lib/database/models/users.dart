class User {
  final String id;
  final String? name;
  final String? email;
  final String? avatarUrl;
  final int? updatedAt;

  User({
    required this.id,
    this.name,
    this.email,
    this.avatarUrl,
    this.updatedAt,
  });

  factory User.fromMap(Map<String, dynamic> map) => User(
        id: map['id'],
        name: map['name'],
        email: map['email'],
        avatarUrl: map['avatarUrl'],
        updatedAt: map['updatedAt'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'avatarUrl': avatarUrl,
        'updatedAt': updatedAt,
      };

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    int? updatedAt,
  }) => User(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        updatedAt: updatedAt ?? this.updatedAt,
      );
} 

class User {
  final String id;
  final Profile profile;
  final Settings settings;

  User({required this.id, required this.profile, required this.settings});

  factory User.fromMap(String id, Map<String, dynamic> data) {
    return User(
      id: id,
      profile: Profile.fromMap(data['profile'] ?? {}),
      settings: Settings.fromMap(data['settings'] ?? {}),
    );
  }
}

class Profile {
  final String name;
  final String createdAt;
  final String email;

  Profile({required this.name, required this.createdAt, required this.email});

  factory Profile.fromMap(Map<String, dynamic> data) {
    return Profile(
      name: data['name'] ?? '',
      createdAt: data['createdAt'] ?? '',
      email: data['email'] ?? '',
    );
  }
}

class Settings {
  final String theme;
  final String timezone;

  Settings({required this.theme, required this.timezone});

  factory Settings.fromMap(Map<String, dynamic> data) {
    return Settings(
      theme: data['theme'] ?? '',
      timezone: data['timezone'] ?? '',
    );
  }
}

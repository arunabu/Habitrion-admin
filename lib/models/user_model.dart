class User {
  final String id;
  final Profile profile;
  final Settings settings;

  User({required this.id, required this.profile, required this.settings});

  factory User.fromMap(String id, Map<String, dynamic> data) {
    var profileData = data['profile'];
    var settingsData = data['settings'];

    return User(
      id: id,
      profile: profileData is Map<String, dynamic>
          ? Profile.fromMap(profileData)
          : Profile.empty(),
      settings: settingsData is Map<String, dynamic>
          ? Settings.fromMap(settingsData)
          : Settings.empty(),
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
      name: data['name'] as String? ?? '',
      createdAt: data['createdAt'] as String? ?? '',
      email: data['email'] as String? ?? '',
    );
  }

  factory Profile.empty() {
    return Profile(name: '', createdAt: '', email: '');
  }
}

class Settings {
  final String theme;
  final String timezone;

  Settings({required this.theme, required this.timezone});

  factory Settings.fromMap(Map<String, dynamic> data) {
    return Settings(
      theme: data['theme'] as String? ?? '',
      timezone: data['timezone'] as String? ?? '',
    );
  }

  factory Settings.empty() {
    return Settings(theme: '', timezone: '');
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';
import '../screens/schedule_list_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Create the nested Profile and Settings objects
      final defaultProfile = Profile(
        name: 'Arun',
        email: 'arun@example.com',
        createdAt: DateTime.now().toIso8601String(), // Convert to ISO 8601 string
      );
      final defaultSettings = Settings(theme: 'dark', timezone: 'Asia/Kolkata');

      final defaultUser = User(
        id: 'user_001',
        profile: defaultProfile,
        settings: defaultSettings,
      );
      Provider.of<UserProvider>(context, listen: false).setUser(defaultUser);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    if (userProvider.user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return const ScheduleListScreen();
  }
}
